merge:
    rm -rf merged
    mkdir -p merged
    cp ./v1model-testgen/* ./ebpf-testgen/* merged
    python ~/workspace/playground/py/p4-scripts/group-stfs.py merged

export-p4testgen: merge
    #!/usr/bin/env bash
    ROOT=testdata/p4testgen
    P4SPECTEC=$HOME/workspace/concrete

    # remove existing tests
    rm -rf $ROOT/{ebpf,v1model}
    mkdir -p $ROOT

    # find p4-stf pairs for v1model and copy them into $ROOT/v1model
    dune exec --root $P4SPECTEC/p4spec -- \
        test/sim/test.exe export-tests -arch v1model \
            -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples \
            -stf-dir merged \
            -export-dir $ROOT/v1model

    # find p4-stf pairs for ebpf and copy them into $ROOT/ebpf
    dune exec --root $P4SPECTEC/p4spec -- \
        test/sim/test.exe export-tests -arch ebpf \
            -p4-dir $P4SPECTEC/p4c/testdata/p4_16_samples \
            -stf-dir merged \
            -export-dir $ROOT/ebpf

    rm -rf merged

export-p4-16-samples:
    #!/usr/bin/env bash
    set -euo pipefail

    DST="testdata/p4_16_samples"
    rm -rf "$DST"
    mkdir -p "$DST"
    find p4c/testdata/p4_16_samples -name '*.p4' ! -path 'p4c/testdata/p4_16_samples/fabric_20190420/include/*' \
        -exec cp {} $DST \;
    echo $(ls $DST/*.p4 | wc -l) " files copied to $DST"

export-p4-16-errors:
    #!/usr/bin/env bash
    set -euo pipefail

    DST="testdata/p4_16_errors"
    rm -rf "$DST"
    mkdir -p "$DST"
    find p4c/testdata/p4_16_errors -name '*.p4' \
        -exec cp {} $DST \;
    echo $(ls $DST/*.p4 | wc -l) " files copied to $DST"

export-p4c: export-p4-16-samples export-p4-16-errors
    #!/usr/bin/env bash
    ROOT=testdata/p4c
    rm -rf $ROOT/{ebpf,v1model}
    mkdir -p $ROOT/{ebpf,v1model}
    grep -rlE 'include <v1model\.p4>|include "v1model\.p4"' p4c/testdata/p4_16_samples \
        | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then cp "$p4file" "${p4file%.p4}.stf" $ROOT/v1model; fi; done
    grep -rlE 'include <ebpf_model\.p4>|include "ebpf_model\.p4"' p4c/testdata/p4_16_samples \
        | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then cp "$p4file" "${p4file%.p4}.stf" $ROOT/ebpf; fi; done

export-excludes:
    rm -rf testdata/excludes
    cp -R excludes/ testdata/

export-all: export-p4c export-p4testgen
    tar czf testdata.tar.gz testdata
    git add testdata.tar.gz
