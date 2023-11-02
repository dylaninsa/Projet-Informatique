Unit configurationPartie;


Interface

uses unite, Crt, sysutils, partie, affichage;

procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);
//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);
procedure nouvellePartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);
procedure creerPlateau(var plat:Plateau; environnement:Enviro);


Implementation


procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);

var c : Integer;

begin 
    {Choix nouvelle / charger partie}
    writeln('Voulez-vous créer une nouvelle partie ou charger une parite ? ');
    writeln('   1 : Lancer une nouvelle partie');
    writeln('   2 : Charger une partie');

    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 2));

    case c of
        1 : nouvellePartie(joueurs, plat, etui);
        //2 : chargerPartie(joueurs, plateau, etui);
    end;
end;


procedure nouvellePartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);

var environnement : Enviro;
    nb_j, i, j, k, l, c, r1, r2, r3, r : Integer;
    cartes, personnages : set of ListeCartes;
    carte : ListeCartes;
    liste_cartes : Array of ListeCartes;
    personnage, p, mem : ListeCartes;

begin
    Randomize;

    {Choix de l'environnement Manoir / INSA}
    writeln('Quel environnement voulez-vous ? ');
    writeln('   1 : Manoir');
    writeln('   2 : INSA');

    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 2));

    case c of
        1 : environnement := Manoir;
        2 : environnement := INSA;
    end;


    {Création du plateau de jeu}
    creerPlateau(plat, environnement);


    {Mise en place des ensembles et des listes de cartes pour l'environnement choisi}
    SetLength(liste_cartes, 20);
    cartes := [];
    personnages := [];
    j := 1;

    if (environnement = Manoir) then
        begin
            for carte := Colonel_Moutarde to Hall do 
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
    r1 := random(5)+1;
    etui[0] := liste_cartes[r1];        // tirage du personnage
    Exclude(cartes, liste_cartes[r1]);

    r2 := random(6)+6;
    etui[1] := liste_cartes[r2];        // tirage de l'arme
    Exclude(cartes, liste_cartes[r2]);

    r3 := random(9)+12;
    etui[2] := liste_cartes[r3];        // tirage du lieu
    Exclude(cartes, liste_cartes[r3]);


    {Mise à jour de la liste de cartes}
    SetLength(liste_cartes, 17);
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
    writeln('Combien y a-t-il de joueurs ?');
    readln(nb_j);
    SetLength(joueurs, nb_j); 


    {Initialisation des joueurs et de leurs propriétés}
    for i := 1 to nb_j do
        begin
            writeln('Quel est le personnage du joueur ', i, ' ?');
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
                Le_Directeur :  begin
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


    {Tests : affichage de l'étui (à enlever plus tard)}
    writeln('Etui');
    for carte in etui do write(carte, ' ');
    Delay(5000);


    {Distribution des cartes}
    for l := 0 to length(liste_cartes)-1 do
        begin
            case l mod nb_j of
                0 : if nb_j >= 1 then Include(joueurs[1].cartes, liste_cartes[l]);
                1 : if nb_j >= 2 then Include(joueurs[2].cartes, liste_cartes[l]);
                2 : if nb_j >= 3 then Include(joueurs[3].cartes, liste_cartes[l]);
                3 : if nb_j >= 4 then Include(joueurs[4].cartes, liste_cartes[l]);
                4 : if nb_j >= 5 then Include(joueurs[5].cartes, liste_cartes[l]);
            end;
        end; 
    
    {Libération espace mémoire}
    SetLength(liste_cartes, 0);


    jeu(etui, plat, joueurs);


    {Tests : affichage de tous les attributs de tout les joueurs (à enlever plus tard)
    for i := 1 to nb_j do
        begin
            writeln(joueurs[i].perso);
            writeln(joueurs[i].enVie);
            writeln(joueurs[i].pos[1], joueurs[i].pos[2]);
            for carte in joueurs[i].cartes do write(carte, ' ');
            writeln();
        end;}
    
    

    {Libération espace mémoire}
    SetLength(joueurs, 0); // le laisser à la fin de cette procédure

end;



procedure creerPlateau(var plat:Plateau; environnement:Enviro);

var fic	: Text;
   i, j : Integer;
   str, x, y, space, co : string;
   carte : ListeCartes;
   test : Coords; // à enlever plus tard

begin
    {Chargement de la grille}
    assign(fic, 'cluedo.txt');
    reset(fic);
    for j := 1 to 27 do
        begin
	        readln(fic,str);
	        for i := 1 to 26 do
		        case str[i] of
			        '0' : plat.grille[i][j] := 0;
			        '1' : plat.grille[i][j] := 1;
	            end;
        end;
    

    {Chargement des cases des salles}
    readln(fic, space);
    for i := 1 to 9 do
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
        for carte := Cuisine to Hall do
            begin
                plat.salles[i].nom := carte;
                i := i+1;
            end
    else
        for carte := Cafete to BU do
            begin
                plat.salles[i].nom := carte;
                i := i+1;
            end;
    close(fic);


    {Chargement du nombre de joueurs par salle}
    for i := 1 to 9 do
        plat.salles[i].nb_j := 0;


    {Tests : Affichage des salles
    for i := 1 to 9 do
        begin
            writeln(plat.salles[i].nom);
            for test in plat.salles[i].cases do
                write(test[1],' ',  test[2], ' / ');
        end;}

end;

//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);


end.