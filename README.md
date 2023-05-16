# Implementacja BPDU Guard oraz Root Guard

## Wstęp

Celem ćwiczenia jest napisanie programu w języku P4 symulującego zachowanie
mechanizmów BPDU Guard oraz Root Guard.

W ramach ćwiczenia użyta będzie topologia składająca się z jednego switcha (s1) z podłączonym na porcie 1
hostem (h1)

![topology](./topo.png)

Program wgrywany na switch s1 znajduje się w pliku `s1.p4`. Rozwiązania znajdują się w folderze `solutions`. 

## Testowanie rozwiązania

W celu kompilacji programu oraz wgraniu na wirtualne środowisko:
   ```bash
   make run
   ```
Zatrzymanie środowiska:
   ```bash
   make stop
   ```
Usunięci plików powstałych w czasie testowania
   ```bash
   make clean
   ```


## Implementacja BPDU Guard

## Relevant Documentation

The documentation for P4_16 and P4Runtime is available [here](https://p4.org/specs/)

All excercises in this repository use the v1model architecture, the documentation for which is available at:
1. The BMv2 Simple Switch target document accessible [here](https://github.com/p4lang/behavioral-model/blob/master/docs/simple_switch.md) talks mainly about the v1model architecture.
2. The include file `v1model.p4` has extensive comments and can be accessed [here](https://github.com/p4lang/p4c/blob/master/p4include/v1model.p4).