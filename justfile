merge:
    rm -rf merged
    mkdir -p merged
    cp ./v1model-testgen/* ./ebpf-testgen/* merged
    python ~/workspace/playground/py/p4-scripts/group-stfs.py merged

export-all: merge
    #!/usr/bin/env bash
    rm -rf extended/{ebpf,v1model}
    mkdir -p extended
    P4SPECTEC=$HOME/workspace/concrete
    dune exec --root $P4SPECTEC/p4spec -- test/sim/test.exe export-tests -arch v1model -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples -stf-dir merged -export-dir extended/v1model
    dune exec --root $P4SPECTEC/p4spec -- test/sim/test.exe export-tests -arch ebpf -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples -stf-dir merged -export-dir extended/ebpf
    grep -rlE 'include <v1model\.p4>|include "v1model\.p4"' $P4SPECTEC/p4c/testdata/p4_16_samples \
        | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then cp "$p4file" "${p4file%.p4}.stf" extended/v1model; fi; done
    grep -rlE 'include <ebpf_model\.p4>|include "ebpf_model\.p4"' $P4SPECTEC/p4c/testdata/p4_16_samples \
        | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then cp "$p4file" "${p4file%.p4}.stf" extended/ebpf; fi; done
    rm -rf merged
    tar cvzf extended.tar.gz extended
    echo "Exported tests located in extended/v1model and extended/ebpf"
