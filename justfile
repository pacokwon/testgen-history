merge:
    rm -rf merged
    mkdir -p merged
    cp ./v1model-testgen/* ./ebpf-testgen/* merged
    python ~/workspace/playground/py/p4-scripts/group-stfs.py merged

export-p4testgen: merge
    #!/usr/bin/env bash
    rm -rf p4testgen/{ebpf,v1model}
    mkdir -p p4testgen
    P4SPECTEC=$HOME/workspace/concrete
    dune exec --root $P4SPECTEC/p4spec -- test/sim/test.exe export-tests -arch v1model -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples -stf-dir merged -export-dir p4testgen/v1model
    dune exec --root $P4SPECTEC/p4spec -- test/sim/test.exe export-tests -arch ebpf -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples -stf-dir merged -export-dir p4testgen/ebpf
    rm -rf merged
    tar cvzf p4testgen.tar.gz p4testgen
    git add p4testgen.tar.gz p4testgen
    echo "Exported tests located in p4testgen/v1model and p4testgen/ebpf"
