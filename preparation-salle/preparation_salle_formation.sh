MACHINES="1 2 3 4 5 6 7 8 9"

# installation des outils pour la formation
for i in ${MACHINES}; do
  ssh cours@formation${i}-rocq.inria.fr "sudo aptitude install ocaml ledit emacs kate gedit";
  done

# test de lancement du toplevel avec ledit
for i in ${MACHINES}; do ssh cours@formation${i}-rocq.inria.fr "ledit ocaml"; done

# installation du mode caml pour emacs pour l'utilisateur cours
for i in ${MACHINES}; do
  ssh cours@formation${i}-rocq.inria.fr "\
  mkdir -p .site-lisp ; \
  cd .site-lisp ; \
  wget http://caml.inria.fr/pub/docs/u3-ocaml/emacs/ocaml.emacs.tgz; \
  tar xvfz ocaml.emacs.tgz ; " ; \
  scp ocaml.emacs cours@formation${i}-rocq.inria.fr:.emacs ; \
  done
