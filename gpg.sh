#!/usr/bin/fish

function gpg_table
    set name $argv[1]
    set -e argv[1]
    set keys (echo $argv|tr ' ' '\n'|sort|uniq)
    set N (count $keys)
    set S (math "$N * $N - $N")
    gpg --recv-keys $keys # 2>| tail -n 2 | grep -q 'gpg: Total number processed:'
    #and exit
    echo '<!DOCTYPE html><html><head><meta charset="utf-8"><style> td, th { border: 1px solid black; min-width: 2em;} table { border-collapse: collapse; text-align: center; font-family: DejaVu Sans Monospace, monospace; } .r { background: red; } .g { background: green; }</style><title>qui a signé qui ?</title></head><body><p>Est-ce que la clef de la ligne a signé la clef de la colonne ?</p><br><table><tr><td>clef</td><td>nom</td><td>N°</td>' > {$name}.html
    set c 1
    for k in $keys
        echo "<th>$c</th>" >> {$name}.html
        set c (math $c + 1)
    end
    set c 1
    for i in $keys
        echo "</tr><tr><th>$i</th><th>" >> {$name}.html
        gpg --fingerprint $i | grep uid | head -n 1 | cut -d] -f2 | cut -d'<' -f1 >> {$name}.html
        echo "</th><th>$c</th>" >> {$name}.html
        for j in $keys
            if [ $i != $j ]
                gpg --list-sigs $j | grep -q $i
                and echo '<td class="g">✔</td>' >> {$name}.html
                or  echo '<td class="r">✘</td>' >> {$name}.html
            else
                echo '<td></td>' >> {$name}.html
            end
        end
        echo -n -e "\r$name html: $c / $N"
        set c (math $c + 1)
    end
    echo
    echo "</tr></table><script> var g = document.querySelectorAll('.g').length; </script><p>Signatures : <script>document.write(g);</script> / $S (<script>document.write(Math.round(100*g/$S));</script>%)</p></body></html>" >> {$name}.html
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
end

gpg_table net7 0031234D 0E38CD1F 0E999B9E 16D85D33 2F5788E9 4653CF28 8FCBF3FB DD5D7D00 E9586D75 F3B2CEDE 888E8A09 4CBA45E8
gpg_table CdL14 089047FE 382A5C4D 4653CF28 552CF98B 5F4445B5 682A3916 6B17EA1E 72F93B05 78758817 C2AA477E DD999172 F3B2CEDE
gpg_table fosdem15 (curl https://ksp.fosdem.org/keys/|grep unknown|cut -d'"' -f8|sed 's/........//'|grep -v 132B94A6)

scp {net7,CdL14,fosdem15}.{html,txt} n7:www_public/pgp
rm -vf {net7,CdL14,fosdem15}.{html,txt}
