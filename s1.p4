/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;

const macAddr_t STP_ADDR = 0x0180C2000000;
const bit<16> ROOT_ID = 7;


header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> ethertype;
}


header bpdu_t {
    bit<24> llc;
    bit<40> proc_data;
    bit<16> root_id;
}


typedef bit<2> guard_t;
const guard_t NO_GUARD = 0;
const guard_t BPDU_GUARD = 1;
const guard_t ROOT_GUARD = 2;

struct metadata {
    guard_t guard;
}

struct headers {
    ethernet_t   ethernet;
    bpdu_t bpdu;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethertype {
        transition accept;
    }
    
    state parse_bpdu {
        packet.extract(hdr.bpdu);
        transition accept;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.dstAddr) {
            STP_ADDR : parse_bpdu;
            default : parse_ethertype;
        }
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action mac_forward(egressSpec_t port) {
        standard_metadata.egress_spec = port;
    }

    action no_guard() {
        meta.guard = NO_GUARD;
    }

    action set_guard(guard_t guard) {
        meta.guard = guard;
    }

    table guard_lookup {
    key = {
        standard_metadata.ingress_port : exact;
    }
    actions = {
        no_guard;
        set_guard;
    }
    size = 1024;
    default_action = no_guard;
    }


    apply {
        if (!hdr.ethernet.isValid()) return;
        guard_lookup.apply();

        if (hdr.bpdu.isValid()) {
            if (meta.guard == BPDU_GUARD) {drop(); return;}
            if (meta.guard == ROOT_GUARD && hdr.bpdu.root_id < ROOT_ID) {drop(); return;}
        }

        if(standard_metadata.ingress_port != 4) mac_forward(4);

    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    action drop() {
        mark_to_drop(standard_metadata);
    }

    apply {
        // Prune multicast packet to ingress port to preventing loop
        if (standard_metadata.egress_port == standard_metadata.ingress_port)
            drop();
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {

    }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.bpdu);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;