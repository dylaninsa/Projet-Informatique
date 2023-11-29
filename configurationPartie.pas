Unit configurationPartie;


Interface


uses unite, Crt, sysutils;


procedure configPartie(var joueurs : ListeJoueurs; var plat : Plateau; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure nouvellePartie(var joueurs : ListeJoueurs;  var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure chargerPartie(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);
procedure creerPlateau(var plat : Plateau; environnement : Enviro);


Implementation


procedure configPartie(var joueurs : ListeJoueurs; var plat : Plateau; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);

var c : Integer;

begin 
    {Choix nouvelle / charger partie}
    writeln('Voulez-vous creer une nouvelle partie ou charger une partie ? ');
    writeln('   1 : Lancer une nouvelle partie');
    writeln('   2 : Charger une partie');

    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 2));

    case c of
        1 : nouvellePartie(joueurs, etui, environnement, j_actif);
        2 : chargerPartie(joueurs, etui, environnement, j_actif);
    end;

    creerPlateau(plat, environnement);
end;



procedure nouvellePartie(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; var environnement : Enviro; var j_actif : Integer);

var nb_j, i, j, k, l, c, r1, r2, r3, r : Integer;
    cartes, personnages : set of ListeCartes;
    carte : ListeCartes;
    liste_cartes : Array of ListeCartes;
    personnage, p, mem : ListeCartes;

begin
    Randomize;
    j_actif := 1;

    {Choix de l'environnement Manoir / INSA}
    writeln('Quel environnement voulez-vous ? ');
    writeln('   1 : Manoir');
    writeln('   2 : INSA');

    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix est invalide.')
    until ((c >= 1) AND (c <= 2));

    case c of
        1 : environnement := Manoir;
        2 : environnement := INSA;
    end;


    {Mise en place des ensembles et des listes de cartes pour l'environnement choisi}
    SetLength(liste_cartes, 21);
    cartes := [];
    personnages := [];
    j := 1;

    if (environnement = Manoir) then
        begin
            for carte := Colonel_Moutarde to Studio do 
                begin
                    Include(cartes, carte);
                    liste_cartes[j] := carte;
                    j := j+1;
                end;
            for personnage := Colonel_Moutarde to Madame_Leblanc do Include(personnages, personnage);
        end
    else
        begin
            for carte := Monsieur_bredel to BU do 
                begin
                    Include(cartes, carte);
                    liste_cartes[j] := carte;
                    j := j+1;
                end;
            for personnage := Monsieur_Bredel to Infirmiere do Include(personnages, personnage);
        end;


    {Tirage aléatoire de l'étui de l'étui}
    r1 := random(6)+1;
    etui[1] := liste_cartes[r1];        // tirage du personnage
    Exclude(cartes, liste_cartes[r1]);

    r2 := random(6)+7;
    etui[2] := liste_cartes[r2];        // tirage de l'arme
    Exclude(cartes, liste_cartes[r2]);

    r3 := random(9)+13;
    etui[3] := liste_cartes[r3];        // tirage du lieu
    Exclude(cartes, liste_cartes[r3]);


    {Mise à jour de la liste de cartes}
    SetLength(liste_cartes, 18);
    j := 0;

    for carte in cartes do 
        begin
            liste_cartes[j] := carte;
            j := j+1;
        end;
    

    {Mélange des cartes}
    for k := 0 to length(liste_cartes)-1 do
        begin
            r := random(length(liste_cartes)-k)+k;
            mem := liste_cartes[r];
            liste_cartes[r] := liste_cartes[k];
            liste_cartes[k] := mem;
        end;


    {Choix du nombre de joueurs dans la partie}
    repeat
        writeln('Combien y a-t-il de joueurs ?');
        readln(nb_j);
        if not((nb_j >= 2) AND (nb_j <= 6)) then
            writeln('Ce choix est invalide.')
        until ((nb_j >= 2) AND (nb_j <= 6));
    SetLength(joueurs, nb_j); 


    {Initialisation des joueurs et de leurs propriétés}
    for i := 1 to nb_j do
        begin
            write('Quel est le personnage du joueur ', i, ' ? Voici les choix possibles : ');
            for carte in personnages do write(carte, ' ');
            writeln();
            repeat
                readln(p);
                if not(p in personnages) then
                    writeln('Ce personnage n''est pas disponible.')
            until (p in personnages);
            joueurs[i].perso := p;
            Exclude(personnages, joueurs[i].perso);
            case p of
                Colonel_Moutarde :  begin
                                        joueurs[i].pos[1] := 2;
                                        joueurs[i].pos[2] := 19;
                                        joueurs[i].pion := 'M';
                                    end;
                Docteur_Olive :     begin
                                        joueurs[i].pos[1] := 16;
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'O';
                                    end;
                Madame_Pervenche :  begin
                                        joueurs[i].pos[1] := 25;
                                        joueurs[i].pos[2] := 8;
                                        joueurs[i].pion := 'P';
                                    end;
                Mademoiselle_Rose : begin
                                        joueurs[i].pos[1] := 9;
                                        joueurs[i].pos[2] := 26;
                                        joueurs[i].pion := 'R';
                                    end;
                Madame_Leblanc :    begin
                                        joueurs[i].pos[1] := 11;
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'L';
                                    end;
                Professeur_Violet :    begin
                                        joueurs[i].pos[1] := 25;
                                        joueurs[i].pos[2] := 21;
                                        joueurs[i].pion := 'V';
                                    end;
                Monsieur_Bredel :  begin
                                        joueurs[i].pos[1] := 2;
                                        joueurs[i].pos[2] := 19;
                                        joueurs[i].pion := 'B';
                                    end;
                Madame_LArcheveque :     begin
                                        joueurs[i].pos[1] := 16;
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'A';
                                    end;
                Directeur :  begin
                                        joueurs[i].pos[1] := 25;
                                        joueurs[i].pos[2] := 8;
                                        joueurs[i].pion := 'D';
                                    end;
                Yohann_Lepailleur : begin
                                        joueurs[i].pos[1] := 9;
                                        joueurs[i].pos[2] := 26;
                                        joueurs[i].pion := 'Y';
                                    end;
                Infirmiere :    begin
                                        joueurs[i].pos[1] := 11;
                                        joueurs[i].pos[2] := 2;
                                        joueurs[i].pion := 'I';
                                    end;
                Monsieur_Thibault :    begin
                                        joueurs[i].pos[1] := 25;
                                        joueurs[i].pos[2] := 21;
                                        joueurs[i].pion := 'T';
                                    end;
            end;
            joueurs[i].enVie := True;
            joueurs[i].cartes := [];
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


    {Distribution des cartes}
    for l := 0 to length(liste_cartes)-1 do
        begin
            case l mod nb_j of
                0 : Include(joueurs[1].cartes, liste_cartes[l]);
                1 : Include(joueurs[2].cartes, liste_cartes[l]);
                2 : Include(joueurs[3].cartes, liste_cartes[l]);
                3 : Include(joueurs[4].cartes, liste_cartes[l]);
                4 : Include(joueurs[5].cartes, liste_cartes[l]);
                5 : Include(joueurs[6].cartes, liste_cartes[l]);
            end;
        end; 
    
    {Libération espace mémoire}
    SetLength(liste_cartes, 0);



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

var nomFichier : String;
    sauvegarde : Text;
    ligne : string;
    nb_j, nb_cartes, i, j : Integer;

begin

    {Choix du fichier à lancer}
    repeat
        write('Entrer le nom de la partie a lancer (avec .txt en extension) : ');
        readln(nomFichier);
        if not(FileExists(nomFichier)) then
            writeln('Ce fichier n''existe pas ou est invalide.')
        until FileExists(nomFichier);
    assign(sauvegarde, nomFichier);
    reset(sauvegarde);

    readln(sauvegarde, ligne);
    if (ligne='Manoir') then
        environnement:=Manoir
    else 
        environnement:=INSA;


    {Nombre de joueurs dans la partie}
    readln(sauvegarde,ligne);
    nb_j:=strtoInt(ligne);
    SetLength(joueurs, nb_j); 


    {Initialisation des joueurs, de leurs propriétés et de leurs cartes}
    for i := 1 to nb_j do
        begin
            readln(sauvegarde, ligne);
            if (ligne='TRUE') then 
                joueurs[i].enVie:=True
            else 
                joueurs[i].enVie:=False;
           
            joueurs[i].cartes := [];
            readln(sauvegarde, ligne);
            for j:=1 to StrToInt(ligne) do
                begin
                    readln(sauvegarde, ligne);
                    Include(joueurs[i].cartes, StrToListeCartes(ligne));
                end;
           
            
            readln(sauvegarde, ligne);
            joueurs[i].pos[1] := StrToInt(ligne);
            readln(sauvegarde, ligne);
            joueurs[i].pos[2] := StrToInt(ligne);
            
            readln(sauvegarde, ligne);
            joueurs[i].perso :=StrToListeCartes(ligne);
           
            readln(sauvegarde, ligne);
            joueurs[i].pion := ligne[1];
        end;
    
    for i := 1 to 3 do
        begin
            readln(sauvegarde, ligne);
            etui[i] := StrToListeCartes(ligne);
        end;

    readln(sauvegarde,ligne);
    j_actif:=StrToInt(ligne);

    {fermeture du fichier}
    close(sauvegarde);
end;



procedure creerPlateau(var plat : Plateau; environnement : Enviro);

var fic	: Text;
   i, j : Integer;
   str, x, y, space, co : string;
   carte : ListeCartes;
   test : Coords; // à enlever plus tard

begin
    {Chargement de la grille}
    assign(fic, 'cluedo.txt');
    reset(fic);
    for j := 1 to 28 do
        begin
	        readln(fic,str);
	        for i := 1 to 26 do
		        case str[i] of
			        '0' : plat.grille[i][j] := 0;
			        '1' : plat.grille[i][j] := 1;
                    '2' : plat.grille[i][j] := 2;
                    '3' : plat.grille[i][j] := 3;
	            end;
        end;
    

    {Chargement des cases des salles}
    readln(fic, space);
    for i := 1 to 10 do
        begin
            readln(fic, str);
            for j := 1 to StrToInt(str) do
                begin
                    readln(fic, co);
                    if (co[2] = ' ') then
                        begin
                            x := Copy(co, 1, 1);
                            if (co[4] = ' ') then
                                y := Copy(co, 3, 1)
                            else
                                y := Copy(co, 3, 2);
                        end
                    else
                        begin
                            x := Copy(co, 1, 2);
                            if (co[5] = ' ') then
                                y := Copy(co, 4, 1)
                            else
                                y := Copy(co, 4, 2);
                        end;
                    plat.salles[i].cases[j][1] := StrToInt(x);
                    plat.salles[i].cases[j][2] := StrToInt(y);
                end;
            readln(fic, space);
        end;


    {Chargement des noms des salles}
    i := 1;
    if environnement = Manoir then
        for carte := Cuisine to Cluedo do
            begin
                plat.salles[i].nom := carte;
                i := i+1;
            end
    else
        for carte := Cafete to Accueil do
            begin
                plat.salles[i].nom := carte;
                i := i+1;
            end;

    
    {fermeture du fichier}
    close(fic);


    {Tests : Affichage des salles
    for i := 1 to 9 do
        begin
            writeln(plat.salles[i].nom);
            for test in plat.salles[i].cases do
                write(test[1],' ',  test[2], ' / ');
        end;}

end;


end.