#!/bin/bash

# Grégoire Delacroix - Kévin Avot - Maxence Boisédu

test $# -lt 1 && echo "Need a directory as parameter" && exit 1
test $# -gt 4 && echo "Too much parameters" && exit 1

#Les paramètres à l'appel du fichier
R=1;d=1;n=1;s=1;m=1;l=1;e=1;t=1;p=1;g=1
#Stockage du nom du fichier actuel
file="${@: -1}"
args=
args2=
#Liste des noms de fichiers
liste="";

#sauvegarde de l'IFS par défaut
save=$IFS

#Gestion du cas des paramètres nsmletpg
function nsmletpg() {
    #Le ou les paramètres
    str=$1
    #Le nombre de paramètres
    number=`expr ${#str} - 1`
    for car in `seq 1 $number`
    do
        #Le caractère actuel
        car=${str:$car:1}
        case $car in
        n) if test $n -eq 0
            then echo "Problem of parameters" && exit 1
            else n=0
            fi;;
        s) if test $s -eq 0
            then echo "Problem of parameters" && exit 1
            else s=0
            fi;;
        m) if test $m -eq 0
            then echo "Problem of parameters" && exit 1
            else m=0
            fi;;
        l) if test $l -eq 0
            then echo "Problem of parameters" && exit 1
            else l=0
            fi;;
        e) if test $e -eq 0
            then echo "Problem of parameters" && exit 1
            else e=0
            fi;;
        t) if test $t -eq 0
            then echo "Problem of parameters" && exit 1
            else t=0
            fi;;
        p) if test $p -eq 0
            then echo "Problem of parameters" && exit 1
            else p=0
            fi;;
        g) if test $g -eq 0
            then echo "Problem of parameters" && exit 1
            else g=0
            fi;;
        *) echo "Problem of parameters" && exit 1
        esac
    done
}

#Tester les paramètres qui ont été rentrés
for par in `seq 1 $#`
do
    case ${!par} in
    -R) R=0
        args="$args -R";;
    -d) d=0
        args="$args -d";;
    $file) ;;
    -*) nsmletpg ${!par}
        args="$args ${!par}"
        args2="$args2""${!par:1}";;
    *) echo "Problem of parameters" && exit 1
    esac
done

#Lister le contenu du répertoire récursivement ou non
if test -d "$file"
then
    for i in "$file"/*
    do
        #Stockage du fichier
        liste="$liste""$i":
    done
fi


#Inverser une liste de fichier (remplaçable par tac -s)
function reverseListe() {
    r=""
    for file in $liste;
    do
        r="$file":"$r"
    done
    liste=$r
}

#calcule la taille en fonction de si le paramètre 1 est un fichier ou un répertoire
function getTaille() {
    value=0
    if test ! -d "$1"
        then
            value=`wc -c < "$1"`
        #else
            #value=`du -b < "$1"` #du ne marche pas
    fi
    echo $value
}

function getNbLigne() {
    value=0
    if test -f $1
    then
        value=`wc -l < $1`
    fi
    echo $value
}

function getExt() {
    ext=""
    if test ! -d $1
    then
        ext=`echo $1 | sed 's/.*\(\..*\)$/\1/'`
    fi
    echo $ext
}

#formatage avec le séparateur :
function formatage() {
    res=""
    for file in $@
    do
        res="$res""$file":
    done
    
    echo "$res"
}

#attribue un chiffre correspondant à la priorité du type, plus le chiffre est petit plus le fichier est prioritaire
function valueType(){
    echo $1
    if test "$1" = "directory"
    then echo 1
    elif test "$1" = "regular file"
    then echo 2
    elif test "$1" = "symbolic link"
    then echo 3
    elif test "$1" = "block device file"
    then echo 4
    elif test "$1" = "character device file"
    then echo 5
    elif test "$1" = "named pipe"
    then echo 6
    else
        echo 7
    fi
}

#parametre: le tri sous la forme s,m,l,e,t,p,g et les deux arguments à comparer 
#retourne 1 si $2 > $3, 0 sinon
function ordre() {
    ret=0
    if test "$1" = "s" -o "$1" = "l"
    then 
        if test $2 -gt $3
        then ret=1
        fi
    else
        if test "$2" \> "$3"
        then ret=1
        fi
    fi
    echo $ret
}

#retourne 1 si $2 = $3, 0 sinon
function egalite() {
    ret=0
    if test "$1" = "s" -o "$1" = "l"
    then 
        if test $2 -eq $3
        then ret=1
        fi
    else
        if test "$2" = "$3"
        then ret=1
        fi
    fi
    echo $ret
}

function triGlobal() {
    l=$*
    lim=`expr $# + 1`
    
    # Tri utilisé : tri par insertion
    
    #on commence à 3 car c'est le deuxième élément de notre liste sans le répertoire courant
    for ((i=3; $lim - $i ; i++))
    do
        x=${@:i:1} #mot que l'on va décaler dans la liste si besoin
        
        j=$i #fait partie de la condition d'arrêt de la boucle while
        jmoins=`expr $j - 1` #variable pour contenir la valeur de j-1
        
        y1=${@:j:1} #y1 sera le rep/fichier liste[j] de la liste en paramètre
        
        y2=${@:jmoins:1} # y2 sera le rep/fichier liste[j-1] de la liste en paramètre

        case $1 in
            s)  valX=`getTaille $x`
                valY2=`getTaille $y2`;;
            m)  valX=`stat -c %y $x`
                valY2=`stat -c %y $y2`;;
            l)  valX=`getNbLigne $x`
                valY2=`getNbLigne $y2`;;
            e)  valX=`getExt $x`
                valY2=`getExt $y2`;;
            t)  valX=`stat -c %F $x`
                valX=`valueType "$valX"`
                valY2=`stat -c %F $y2`
                valY2=`valueType "$valY2"`;;
            p)  valX=`stat --format %U $x`
                valY2=`stat --format %U $y2`;;
            g)  valX=`stat --format %G $x`
                valY2=`stat --format %G $y2`;;
        esac

        cond=`ordre "$1" "$valY2" "$valX"`
        while test $j -gt 2 -a $cond -eq 1
        do
            l=${l/$y1/$y2}
            set -- $l  # permet de mettre à jour 
            j=`expr $j - 1`
            jmoins=`expr $jmoins - 1`
            
            y1=${@:j:1}
            y2=${@:jmoins:1}

            if test $jmoins -gt 1
            then case $1 in
                    s)  valY2=`getTaille $y2`;;
                    m)  valY2=`stat -c %y $y2`;;
                    l)  valY2=`getNbLigne $y2`;;
                    e)  valY2=`getExt $y2`;;
                    t)  valY2=`stat -c %F $y2`
                        valY2=`valueType "$valY2"`;;
                    p)  valY2=`stat --format %U $y2`;;
                    g)  valY2=`stat --format %G $y2`;;
                esac
            else
                valY2=0
            fi
            cond=`ordre "$1" "$valY2" "$valX"`
        done
        
        l=${l/$y1/$x}
        
    done

    l=${l/"$1:"/""}
    formatage $l
}

function tris() {
    #Le ou les paramètres
    IFS=$save
    str=$args2
    sorted=0
    number=`expr ${#str} - 1`
    for c in `seq 0 $number`
    do
        car=${str:$c:1}
        IFS=':'
        # -n
        #if test "$n" -eq 0 
        #then 
        #fi
        # -s -m -l -e -t -p -g
        if test $sorted -eq 0
        then
            liste=`triGlobal "$car" $liste`
        else
            listeBis="$liste" # copie de la liste globale, prend tous les changements à la place de la liste globale
            oldCar=`expr $c - 1`
            oldCar=${str:$oldCar:1}
            
            var1=`blocEgaux "$oldCar" $liste`
            
            while test "$var1" != ""
            do
                var2=`triGlobal "$car" $var1`
                liste=${liste/$var1/$var2}
                
                listeBis=${listeBis/$var1/""}
                var1=`blocEgaux "$oldCar" $listeBis`
            done
        fi
        sorted=1
        IFS=$save
    done
    # -d
    if test "$d" -eq 0
    then
        reverseListe
    fi
    IFS=':'
}

# retourne les éléments de la liste qui sont égaux suivant le critère donné en paramètre
function blocEgaux(){
    previous=
    res=""
    
    stat=${@:$#:1}
    lim=`expr $# + 1`
    for ((i=2 ; $# - $i ; i++))
    do
        n=${@:i:1}
        if test -z "$previous"
        then
            previous="$n"
            res="$n"':'
        else
            x=
            y=
            case $1 in
                s)  x=`getTaille $n`
                    y=`getTaille $previous`;;
                m)  x=`stat -c %y $n`
                    y=`stat -c %y $previous`;;
                l)  x=`getNbLigne $n`
                    y=`getNbLigne $previous`;;
                e)  x=`getExt $n`
                    y=`getExt $previous`;;
                t)  x=`stat -c %F $n`
                    x=`valueType "$x"`
                    y=`stat -c %F $previous`
                    y=`valueType "$y"`;;
                p)  x=`stat --format %U $n`
                    y=`stat --format %U $previous`;;
                g)  x=`stat --format %G $n`
                    y=`stat --format %G $previous`;;
            esac
            
            cond=`egalite "$1" "$x" "$y"`
            if test $cond -eq 1
            then
                res="$res""$n"':'
            else
                if test "$res" != "$previous"':'
                then
                    break
                fi
                res="$n"':'
            fi
        fi
        previous=${@:i:1}
    done
    
    echo "$res"
}

#affiche 1 fichier par ligne dans l'ordre de la liste
function printListe() {
    IFS=':'
    tris
    #Affichage
    for file in $liste;
    do
        if test "$R" -eq 0
        then
            echo $file
        else
            echo $file | sed 's/[\.*\/]*//'
        fi
        #Test si c'est un répertoire et si on veut un affichage par récurrence
        #Rajouter des if pour prendre en compte les autres paramètres
        if test "$R" -eq 0 -a -d "$file"
        then
            IFS=$save
            "$0" $args "$file"
            IFS=':'
        fi
        if test "$R" -eq 0 -a -d "$file"
        then
            echo ""
        fi
    done
    IFS=$save
}

printListe