#!/usr/bin/fish

function gpg_table
    set name $argv[1]
    set -e argv[1]
    set n (count $argv)
    echo "$name, $n keys: $argv"
    set keys (echo $argv|tr ' ' '\n'|sort|uniq)
    set N (count $keys)
    if [ $n != $N ]
        echo "collision ? uniq keys: $keys"
        exit
    end
    set S (math "$N * $N - $N")
    gpg --recv-keys $keys
    echo '<!DOCTYPE html><html><head><meta charset="utf-8"><style> td, th { border: 1px solid black; min-width: 2em;} table { border-collapse: collapse; text-align: center; font-family: DejaVu Sans Monospace, monospace; } .r { background: red; } .g { background: green; }</style><title>qui a signé qui ?</title></head><body><p>Est-ce que la clef de la ligne a signé la clef de la colonne ?</p><br><table><tr><td>clef</td><td>nom</td><td>N°</td>' > {$name}.html
    set c 1
    for k in $keys
        echo -n "<th>$c</th>" >> {$name}.html
        set c (math $c + 1)
    end
    echo -n '<th>signed</th>' >> {$name}.html
    set c 1
    for i in $keys
        echo -n "</tr><tr><th>$i</th><th>" >> {$name}.html
        gpg --fingerprint $i | grep uid | head -n 1 | cut -d] -f2 | cut -d'<' -f1 >> {$name}.html
        echo -n "</th><th>$c</th>" >> {$name}.html
        for j in $keys
            if [ $i != $j ]
                gpg --list-sigs $j | grep -q $i
                and echo -n '<td class="g">✔</td>' >> {$name}.html
                or  echo -n '<td class="r">✘</td>' >> {$name}.html
            else
                echo -n '<td></td>' >> {$name}.html
            end
        end
        set total (tail -n1 {$name.html}|grep -o ✔|wc -l)
        echo -n "<td>$total</td>" >> {$name}.html
        echo -n -e "\r$name html: $c / $N"
        set c (math $c + 1)
    end
    echo
    set s (grep -o ✔ {$name}.html | wc -l)
    set p (math "100 * $s / $S")
    echo "</tr></table><p>Signatures : $s / $S ($p%)</p><p>Envoyez vos modifications avec <pre>gpg --send-keys $keys</pre></p></body></html>" >> {$name}.html
    test -f {$name}.txt
    and rm {$name}.txt
    for key in $keys
        gpg --fingerprint $key >> {$name}.txt
    end
    set c 1
    for key1 in $keys
        echo -n $key1 >> {$name}.txt
        for key2 in $keys
            echo -n ' ' >> {$name}.txt
            if [ $key1 = $key2 ]
                echo -n + >> {$name}.txt
            else
                gpg --list-sigs $key2 | grep -q $key1
                and echo -n ✔ >> {$name}.txt
                or echo -n ✘ >> {$name}.txt
            end
        end
        echo >> {$name}.txt
        echo -n -e "\r$name txt: $c / $N"
        set c (math $c + 1)
    end
    echo
    echo "Signatures : $s / $S ($p%)" >> {$name}.txt
end

gpg_table net7 (curl http://www.bde.inp-toulouse.fr/clubs/inp-net/contact.php|grep OpenPGP-Key|cut -d'"' -f 4)
#gpg_table CdL14 089047FE 382A5C4D 4653CF28 552CF98B 5F4445B5 682A3916 6B17EA1E 72F93B05 78758817 C2AA477E DD999172 F3B2CEDE

scp net7.{html,txt} n7:www_public/pgp
rm -vf net7.{html,txt}
