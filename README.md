# Quijote
Scripts para el diseño del MAD-1 "Rocinante"

## Setup

Es recomendable crear un proyecto de Matlab para mantener todos los
archivos organizados
<https://es.mathworks.com/help/matlab/matlab_prog/create-projects.html>,
recordando añadir todas las carpetas al `PATH`.

Para que `Xfoil` funcione es necesario que el archivo `xfoil.exe` este en
la carpeta `Perfil/Xfoil`. Si teneis Linux o Mac podeis crear un enlace
al ejecutable usando los comandos siguientes desde la carpeta `Xfoil`:

* Para saber donde esta el ejecutable: `type xfoil`
* Para crear el enlace: `ln -s /direccion/de/xfoil`

## Guía para usar git

Guía "oficial":
<https://github.github.com/training-kit/downloads/github-git-cheat-sheet.pdf>

Normalmente, antes de empezar es bueno actualizar todo

* `git checkout [branch donde vais a trabajar]`
* `git pull`

Una vez que hayais hecho varios cambios que esten relacionados, haced un
_commit_ con un comentario que los agrupe.

* `git add .`
* `git commit -m "comentario"`

Cuando esteis seguros de que esta todo bien, subid todo al servidor

* `git push`.

### Git cheat sheet

* Actualizar archivos desde el servidor (hacer **siempre** antes de trabajar):
    - `git pull`

* Seleccionar archivos a incluir en el proximo _commit_ (_staged_):
    - `git add [nombre de los archivos]`
    - `git add .` (para añadir todos los cambios)

* Hacer un _commit_:
    - `git commit -m "[comentario que resuma los cambios realizados]"`

* Subir cambios al servidor de **github**:
    - `git push`

* Revisar _commits_ anteriores:
    - `git log`

* Revisar cambios realizados (_staged_ y no):
    - `git status`

* Crear _branch_:
    - `git branch [nombre de branch]`

* Cambiar a otra _branch_:
    - `git checkout [nombre de branch]`

* Unir _branch_ a _master_ (_merge_):
    - `git merge [branch a unir]` (estando en _master_)
