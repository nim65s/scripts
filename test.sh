#!/bin/bash
PS3="Entrez le numéro de votre commande -> "
echo "Que désirez-vous boire ?"
select boisson in "Rien, merci" "Café" "Thé
au lait" "Chocolat"; do
if [ -z "$boisson" ]; then
echo "Erreur: entrez un des chiffres proposés." 1>&2
elif [ "$REPLY" -eq 1 ]; then
echo "Au revoir!"
break
else
echo "Vous avez fait le choix numéro $REPLY..."
echo "Votre $boisson est servi."
fi
echo
done 
exit
