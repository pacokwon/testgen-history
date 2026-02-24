# -- mode: org; --

#+NAME: count-lines
#+begin_src shell :var data="foobar" :exports none
printf "%s" "$data" | wc -l
#+end_src

#+NAME: count-lines-file
#+begin_src shell :var filename="" :exports none
ls $filename | wc -l
#+end_src

#+NAME: count-all-v1model-stfs
#+begin_src shell :exports none
grep -rlE 'include <v1model\.p4>|include "v1model\.p4"' p4c/testdata/p4_16_samples | wc -l
#+end_src

#+NAME: count-all-p4spectec-stfs
#+begin_src shell :exports none
with_stf=$(grep -rlE 'include <v1model\.p4>|include "v1model\.p4"' p4c/testdata/p4_16_samples | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then echo "$p4file"; fi; done | wc -l)
p4testgen_stf=$(ls 1-testgen | wc -l)
custom_stf=$(find testdata/custom -name '*.p4' | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then echo "$p4file"; fi; done | wc -l)
echo $((with_stf+p4testgen_stf+custom_stf))
#+end_src

#+NAME: count-testgen-stfs
#+begin_src shell :exports none
ls 1-testgen | wc -l
#+end_src

#+NAME: count-custom-stfs
#+begin_src shell :exports none
find testdata/custom -name '*.p4' | while read p4file; do if [ -f "${p4file%.p4}.stf" ]; then echo "$p4file"; fi; done | wc -l
#+end_src

#+NAME: use-result
#+begin_src shell :results output :var data="" :exports none
echo $data
#+end_src
