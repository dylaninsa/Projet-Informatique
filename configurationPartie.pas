Unit configurationPartie;


Interface


uses unite, Crt, sysutils;


procedure configPartie(var joueurs : ListeJoueurs; var plat : Plateau; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure nouvellePartie(var joueurs : ListeJoueurs;  var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure chargerPartie(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure creerPlateau(var plat : Plateau; environnement : Enviro);


Implementation


procedure configPartie(var joueurs : ListeJoueurs; var plat : Plateau; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
{Procedure qui va appeler nouvellePartie ou chargerParite pour configurer les parametres de la partie}

var c : Integer;

begin 
    writeln('Voulez-vous creer une nouvelle partie ou charger une partie ? ');  // Demande a l'utilisateur si il veut charger ou creer une nouvelle partie
    writeln('   1 : Creer nouvelle partie');
    writeln('   2 : Charger une partie');

    repeat  // Boucle se repetant jusqu'a ce que le choix de l'utilisateur soit valide
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 2));

    case c of
        1 : nouvellePartie(joueurs, etui, environnement, j_actif);  // Appel de la procedure nouvellePartie pour configurer une nouvelle partie
        2 : chargerPartie(joueurs, etui, environnement, j_actif);  // Appel de la procedure chargerPartie pour charger une partie deja existante
    end;

    creerPlateau(plat, environnement);  // Appel de la procedure qui cree le plateau de jeu
end;



procedure nouvellePartie(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
{Procedure initialisant les parametres du jeu d'une nouvelle partie}

var nb_j, i, j, k, l, c, r1, r2, r3, r : Integer;
    cartes, personnages : set of ListeCartes;
    liste_cartes : Array of ListeCartes;
    personnage, p, mem, carte: ListeCartes;
    carteStr : String;

begin
    Randomize;
    j_actif := 1;  // Initialisation du joueur 'actif'

    writeln('Quel environnement voulez-vous ? ');  // Demande a l'utilisateur
    writeln('   1 : Manoir');
    writeln('   2 : INSA');

    repeat  // Boucle se repetant jusqu'a ce que le choix de l'utilisateur soit valide
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix est invalide.')
    until ((c >= 1) AND (c <= 2));

    case c of  // Instruction permettant de traiter les différents cas en fonction du choix de l'utilisateur
        1 : environnement := Manoir;
        2 : environnement := INSA;
    end;


    SetLength(liste_cartes, 21);  // Longueur du tableau dynamique liste_cartes definit a 21, le nombre de cartes total
    cartes := [];  // Initialisation de l'ensemble cartes
    personnages := [];  // Initialisation de l'ensemble personnages
    j := 1;

    if (environnement = Manoir) then  // Verification du choix Manoir pour l'environnement 
        begin
            for carte := Colonel_Moutarde to Studio do  // Boucle incluant toutes les cartes de l'environnement Manoir dans l'ensemble cartes et la liste liste_cartes
                begin
                    Include(cartes, carte);
                    liste_cartes[j] := carte;
                    j := j+1;
                end;
            for personnage := Colonel_Moutarde to Madame_Leblanc do Include(personnages, personnage);  // Boucle incluant toutes les cartes personnages de l'environnement Manoir dans l'ensemble personnage
        end
    else  // Sinon, le choix est INSA pour l'environnement 
        begin
            for carte := Monsieur_bredel to BU do  // Boucle incluant toutes les cartes de l'environnement INSA dans l'ensemble cartes et la liste liste_cartes
                begin
                    Include(cartes, carte);
                    liste_cartes[j] := carte;
                    j := j+1;
                end;
            for personnage := Monsieur_Bredel to Infirmiere do Include(personnages, personnage);  // Boucle incluant toutes les cartes personnages de l'environnement INSA dans l'ensemble personnage
        end;


    {Tirage aléatoire de l'étui de l'étui}
    r1 := random(6) + 1;  // Tirage aleatoire d'un indice d'une carte personnage pour l'etui
    etui[1] := liste_cartes[r1];  // Affectation de la carte personnage a l'etui 
    Exclude(cartes, liste_cartes[r1]);  // Retrait de la carte personnage dans l'ensemble cartes

    r2 := random(6) + 7;  // Tirage aleatoire d'un indice d'une carte arme pour l'etui
    etui[2] := liste_cartes[r2];  // Affectation de la carte arme a l'etui 
    Exclude(cartes, liste_cartes[r2]);  // Retrait de la carte arme dans l'ensemble cartes

    r3 := random(9) + 13;  // Tirage aleatoire d'un indice d'une carte lieu pour l'etui
    etui[3] := liste_cartes[r3];  // Affectation de la carte lieu a l'etui 
    Exclude(cartes, liste_cartes[r3]);  // Retrait de la carte lieu dans l'ensemble cartes


    SetLength(liste_cartes, 18);  // Longueur du tableau dynamique liste_cartes definit a 21, le nombre de cartes total sans l'etui
    j := 0;

    for carte in cartes do  // Boucle mettant a jour la liste liste_cartes avec les elements de l'ensemble cartes
        begin
            liste_cartes[j] := carte;
            j := j+1;
        end;
    

    for k := 0 to length(liste_cartes)-1 do  // Boucle melangeant la liste liste_cartes
        begin
            r := random(length(liste_cartes)-k)+k;  // Generation d'une valeur aleatoire entre la valeur k et la nombre d'element dans la liste_cartes
            mem := liste_cartes[r];  // Permutation des cartes positionnees aux indices k et r
            liste_cartes[r] := liste_cartes[k];
            liste_cartes[k] := mem;
        end;


    writeln('Combien y a-t-il de joueurs ?');
    repeat  // Demande a l'utilisateur le nombre de joueurs de la partie
        readln(nb_j);
        if not((nb_j >= 2) AND (nb_j <= 6)) then
            writeln('Ce choix est invalide.')
        until ((nb_j >= 2) AND (nb_j <= 6));
    SetLength(joueurs, nb_j);   // Longueur du tableau dynamique joueurs definit a nb_j


    for i := 1 to nb_j do  // Boucle demandant les proprietes de chaque joueur
        begin
            write('Quel est le personnage du joueur ', i, ' ? Voici les choix possibles : ');  // Demande au joueur i le nom de son personnage
            for carte in personnages do write(ListeCartesToStr(carte), ', ');  // Affichage des personnages disponibles
            writeln();
            repeat  // Boucle se repetant jusqu'a ce que le personnage choisi soit correcte
                readln(carteStr);
                if StrCorrect(carteStr) then  // Verification de la correspondance entre la chaine de caractere saisie et une carte
                    begin
                        p := StrToListeCartes(carteStr);
                        if not(p in personnages) then  // Verification de la disponibilite du personnage voulu
                            writeln('Ce personnage n''est pas disponible.');
                    end
                else
                    writeln('La saisie est incorrecte.')
            until ((p in personnages) AND StrCorrect(carteStr));

            joueurs[i].perso := p;  // Affectation du personnage au joeur i
            Exclude(personnages, joueurs[i].perso);  // Exclusion du joeur choisi par le joueur i de l'ensemble personnages
            case p of  // Instruction permettant de traiter les différents cas en fonction du personnage choisi par le joeur i
                Colonel_Moutarde :  begin
                                        joueurs[i].pos[1] := 2;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 19;
                                        joueurs[i].pion := 'M';  // Initialisation du pion
                                    end;
                Docteur_Olive :     begin
                                        joueurs[i].pos[1] := 16;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'O';
                                    end;
                Madame_Pervenche :  begin
                                        joueurs[i].pos[1] := 25;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 8;
                                        joueurs[i].pion := 'P';  // Initialisation du pion
                                    end;
                Mademoiselle_Rose : begin
                                        joueurs[i].pos[1] := 9;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 26;
                                        joueurs[i].pion := 'R';  // Initialisation du pion
                                    end;
                Madame_Leblanc :    begin
                                        joueurs[i].pos[1] := 11;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'L';  // Initialisation du pion
                                    end;
                Professeur_Violet :    begin
                                        joueurs[i].pos[1] := 25;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 21;
                                        joueurs[i].pion := 'V';  // Initialisation du pion
                                    end;
                Monsieur_Bredel :  begin
                                        joueurs[i].pos[1] := 2;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 19;
                                        joueurs[i].pion := 'B';  // Initialisation du pion
                                    end;
                Madame_LArcheveque :     begin
                                        joueurs[i].pos[1] := 16;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'A';  // Initialisation du pion
                                    end;
                Directeur :  begin
                                        joueurs[i].pos[1] := 25;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 8;
                                        joueurs[i].pion := 'D';  // Initialisation du pion
                                    end;
                Yohann_Lepailleur : begin
                                        joueurs[i].pos[1] := 9;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 26;
                                        joueurs[i].pion := 'Y';  // Initialisation du pion
                                    end;
                Infirmiere :    begin
                                        joueurs[i].pos[1] := 11;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'I';  // Initialisation du pion
                                    end;
                Monsieur_Thibault :    begin
                                        joueurs[i].pos[1] := 25;  // Initialisation de la position 
                                        joueurs[i].pos[2] := 21;
                                        joueurs[i].pion := 'T';  // Initialisation du pion
                                    end;
            end;
            joueurs[i].enVie := True;  // Initialisation de l'etat de vie du joueur i 
            joueurs[i].cartes := [];  // Initialisation de l'ensemble de cartes du joueur i
        end;


    {Tests : affichage des cartes mélangées (à enlever plus tard)
    writeln('Liste cartes mélangées');
    j := 0;
    for carte in liste_cartes do 
        begin 
            write(j, ':', carte, ' ');
            j := j+1;
        end;
    writeln();}


    {Tests : affichage de l'étui (à enlever plus tard)
    writeln('Etui');
    for i := 1 to 3 do write(etui[i], ' ');
    Delay(5000);}


    for l := 0 to length(liste_cartes)-1 do  // Boucle parcourant les cartes de liste_cartes pour les distribuer aux joueurs
        begin
            case l mod nb_j of  // Instruction permettant de traiter les différents cas en fonction du reste de la division euclidienne de l par le nombre de joueurs
                0 : Include(joueurs[1].cartes, liste_cartes[l]);
                1 : Include(joueurs[2].cartes, liste_cartes[l]);
                2 : Include(joueurs[3].cartes, liste_cartes[l]);
                3 : Include(joueurs[4].cartes, liste_cartes[l]);
                4 : Include(joueurs[5].cartes, liste_cartes[l]);
                5 : Include(joueurs[6].cartes, liste_cartes[l]);
            end;
        end; 
    

    SetLength(liste_cartes, 0);  // Liberation de l'espace memoire



    {Tests : affichage de tous les attributs de tout les joueurs (à enlever plus tard)
    for i := 1 to nb_j do
        begin
            writeln(joueurs[i].perso);
            writeln(joueurs[i].enVie);
            writeln(joueurs[i].pos[1], joueurs[i].pos[2]);
            for carte in joueurs[i].cartes do write(carte, ' ');
            writeln();
        end;}
end;



procedure chargerPartie(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
{Procedure chargeant les parametres d'une sauvegarde}

var nomFichier : String;
    sauvegarde : Text;
    ligne : string;
    nb_j, nb_cartes, i, j : Integer;

begin
    write('Entrer le nom de la partie a lancer (avec .txt en extension) : ');
    repeat  // Boucle se repetant jusqu'a ce que le fichier saisi existe
        readln(nomFichier);
        if not(FileExists(nomFichier)) then  // Verification de l'existance du fichier
            writeln('Ce fichier n''existe pas ou est invalide.')
        until FileExists(nomFichier);
    assign(sauvegarde, nomFichier);  // Liaison entre la variable sauvegarde et le fichier nomFichier
    reset(sauvegarde);  // Lecture du fichier

    readln(sauvegarde, ligne);  // Lecture de l'environnement
    if (ligne='Manoir') then
        environnement:=Manoir  // Initialisation de l'environnement Manoir 
    else 
        environnement:=INSA;  // Initialisation de l'environnement INSA 


    readln(sauvegarde,ligne);  // Lecture du nombre de joueurs dans la partie
    nb_j:=strtoInt(ligne);
    SetLength(joueurs, nb_j);  // Longueur du tableau dynamique joueurs definit a nb_j


    for i := 1 to nb_j do  // Boucle se repetant nb_j fois
        begin
            readln(sauvegarde, ligne);  // Lecture de l'etat de vie du joueur i
            if (ligne='TRUE') then 
                joueurs[i].enVie := True  // Initialisation de l'etat de vie du joueur i
            else 
                joueurs[i].enVie := False;
            joueurs[i].cartes := [];  // Initialisation de l'ensemble de cartes du joueur i
            readln(sauvegarde, ligne);  // Lecture du nombre de cartes du joueur i
            for j:=1 to StrToInt(ligne) do  // Boucle se repetant le nombre de cartes du joueur i fois
                begin
                    readln(sauvegarde, ligne);  // Lecture de la carte j
                    Include(joueurs[i].cartes, StrToListeCartes(ligne));  // Inclusion de la carte j a l'ensemnle de cartes du joueur i
                end;
            readln(sauvegarde, ligne);  // Lecture de la position X du joueur i
            joueurs[i].pos[1] := StrToInt(ligne);  // Initialisation de la position X du joueur i
            readln(sauvegarde, ligne);  // Lecture de la position Y du joueur i
            joueurs[i].pos[2] := StrToInt(ligne);  // Initialisation de la position Y du joueur i
            readln(sauvegarde, ligne);  // Lecture du personnage du joueur i
            joueurs[i].perso := StrToListeCartes(ligne);  // Initialisation du personnage du joueur i
            readln(sauvegarde, ligne);  // Lecture du pion du joueur i
            joueurs[i].pion := ligne[1];  // Initialisation du pion du joueur i
            writeln(i, ' ', joueurs[i].pion);
        end;
    
    for i := 1 to 3 do  // Boucle se repetant 3 fois pour lire les 3 elements de l'etui
        begin
            readln(sauvegarde, ligne);  // Lecture de la carte i de l'etui
            etui[i] := StrToListeCartes(ligne);  // Initialisation de la carte i de l'etui
        end;

    readln(sauvegarde,ligne);  // Lecture du joueur 'actif'
    j_actif:=StrToInt(ligne);  // Initialisation du joueur 'actif'

    close(sauvegarde);  // Fermeture du fichier
end;



procedure creerPlateau(var plat : Plateau; environnement : Enviro);
{Procedure creant le plateau de jeu a partir de l'environnement}

var fic	: Text;
   i, j : Integer;
   str, x, y, space, co : string;
   carte : ListeCartes;
   test : Coords; // à enlever plus tard

begin
    {Chargement de la grille}
    assign(fic, 'cluedo.txt');  // Liaison entre la variable fic et le fichier 'cluedo.txt'
    reset(fic);  // Lecture du fichier
    for j := 1 to 28 do  // Boucle parcourant les lignes du plateau
        begin
	        readln(fic,str);  // Lecture d'un ligne du plateau
	        for i := 1 to 26 do  // Boucle parcourant les colonnes du plateau
		        case str[i] of
			        '0' : plat.grille[i][j] := 0;  // Cas d'une case sur laquelle on peut se deplacer
			        '1' : plat.grille[i][j] := 1;  // Cas d'un mur
                    '2' : plat.grille[i][j] := 2;  // Cas d'un passage secret 1
                    '3' : plat.grille[i][j] := 3;  // Cas d'un passage secret 2
	            end;
        end;
    

    readln(fic, space);  // Lecture d'un retour a la ligne dans le fichier
    for i := 1 to 10 do  // Boucle se repetant autant de fois que le nombre de salle qu'il y a sur le plateau
        begin
            readln(fic, str);  // Lecture du nombre de cases dans la salle i
            for j := 1 to StrToInt(str) do  // Boucle se repetant autant de fois que le nombre de cases dans la salle i
                begin
                    readln(fic, co);  // Lecture des coordonnees de la case j
                    if (co[2] = ' ') then  // Cas d'une coordonnee de la forme 'X_.. '
                        begin
                            x := Copy(co, 1, 1);  // Copiage de la coordonne x de la chaine de caractere co
                            if (co[4] = ' ') then  // Cas d'une coordonnee de la forme 'X_Y '
                                y := Copy(co, 3, 1)  // Copiage de la coordonne y de la chaine de caractere co
                            else  // Cas d'une coordonnee de la forme 'X_YY '
                                y := Copy(co, 3, 2);  // Copiage de la coordonne y de la chaine de caractere co
                        end
                    else  // Cas d'une coordonnee de la forme 'XX_.. '
                        begin
                            x := Copy(co, 1, 2);  // Copiage de la coordonne x de la chaine de caractere co
                            if (co[5] = ' ') then  // Cas d'une coordonnee de la forme 'XX_Y '
                                y := Copy(co, 4, 1)  // Copiage de la coordonne y de la chaine de caractere co
                            else  // Cas d'une coordonnee de la forme 'XX_YY '
                                y := Copy(co, 4, 2);  // Copiage de la coordonne y de la chaine de caractere co
                        end;
                    plat.salles[i].cases[j][1] := StrToInt(x);  // Initialisation de la coordonnee x de la case j de la salle i
                    plat.salles[i].cases[j][2] := StrToInt(y);  // Initialisation de la coordonnee y de la case j de la salle i
                end;
            readln(fic, space);  // Lecture d'un retour a la ligne dans le fichier
        end;


    {Chargement des noms des salles}
    i := 1;
    if environnement = Manoir then  // Verification du choix Manoir pour l'environnement
        for carte := Cuisine to Cluedo do  // Boucle parcourant les cartes salle de l'environnement Manoir
            begin
                plat.salles[i].nom := carte;  // Initialisation du nom de la salle i
                Inc(i);
            end
    else  // Verification du choix INSA pour l'environnement
        for carte := Cafete to Accueil do  // Boucle parcourant les cartes salle de l'environnement INSA
            begin
                plat.salles[i].nom := carte;  // Initialisation du nom de la salle i
                Inc(i);
            end;

    
    
    close(fic);  // Fermeture du fichier


    {Tests : Affichage des salles
    for i := 1 to 9 do
        begin
            writeln(plat.salles[i].nom);
            for test in plat.salles[i].cases do
                write(test[1],' ',  test[2], ' / ');
        end;}

end;


end.