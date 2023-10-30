Unit configurationPartie;


Interface

uses unite, Crt;

procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);
//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);
procedure nouvellePartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);
//procedure creerPlateau(var plateau:Plateau; environnement:Enviro);


Implementation


procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:Array of ListeCartes);

var c : Integer;

begin 
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
    pos_init : Coords;

begin
    Randomize;

    {Choix de l'environnement}
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

    SetLength(liste_cartes, 20);
    cartes := [];
    personnages := [];
    j := 1;

    {Mise en place des enembles et des listes pour l'environnement choisi}
    if (environnement = Manoir) then
        begin
            for carte := Colonel_Moutarde to Hall do 
                begin
                    Include(cartes, carte);
                    liste_cartes[j] := carte;
                    j := j+1;
                end;
            for personnage := Colonel_Moutarde to Madame_Leblanc do Include(personnages, personnage);
        end;
    //else
    //    begin
    //        for carte := Colonel_Moutarde to Hall do 
    //            begin
    //                Include(cartes, carte);
    //                liste_cartes[j] := carte;
    //                j = j+1;
    //            end;
    //        for personnage := Colonel_Moutarde to Madame_Leblanc do Include(personnages, personnage);
    //    end;

    {Tirage de l'étui}
    r1 := random(5)+1;
    etui[0] := liste_cartes[r1];
    Exclude(cartes, liste_cartes[r1]);
    r2 := random(6)+6;
    etui[1] := liste_cartes[r2];
    Exclude(cartes, liste_cartes[r2]);
    r3 := random(9)+12;
    etui[2] := liste_cartes[r3];
    Exclude(cartes, liste_cartes[r3]);

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

    writeln('Combien y a-t-il de joueurs ?');
    readln(nb_j);
    SetLength(joueurs, nb_j-1); 
    pos_init[1] := 0; // à modif
    pos_init[2] := 0; // à modif

    {Initialisation des joueurs}
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
            joueurs[i].enVie := True;
            joueurs[i].pos := pos_init;
            joueurs[i].cartes := [];
        end;

    writeln('Liste cartes mélangées');
    j := 0;
    for carte in liste_cartes do 
        begin 
            write(j, ':', carte, ' ');
            j := j+1;
        end;
    writeln();
    writeln('Etui');
    for carte in etui do write(carte, ' ');
    writeln();
    writeln(joueurs[1].perso);
    for carte in joueurs[1].cartes do write(carte, ' ');
    writeln();

    {Distribution des cartes} // il y a sûrement une erreur
    for l := 0 to length(liste_cartes)-1 do
        begin
            writeln(l, ' ', l mod nb_j, ' ', liste_cartes[l]);
            case l mod nb_j of
                0 : if nb_j >= 1 then Include(joueurs[1].cartes, liste_cartes[l]);
                1 : if nb_j >= 2 then Include(joueurs[2].cartes, liste_cartes[l]);
                2 : if nb_j >= 3 then Include(joueurs[3].cartes, liste_cartes[l]);
                3 : if nb_j >= 4 then Include(joueurs[4].cartes, liste_cartes[l]);
                4 : if nb_j >= 5 then Include(joueurs[5].cartes, liste_cartes[l]);
            end;
        end; 
    
    SetLength(liste_cartes, 0);

    {tests}
    for i := 1 to nb_j do
        begin
            writeln(joueurs[i].perso);
            writeln(joueurs[i].enVie);
            writeln(joueurs[i].pos[1], joueurs[i].pos[2]);
            for carte in joueurs[i].cartes do write(carte, ' ');
            writeln();
        end;
    
    
    SetLength(joueurs, 0); // le laisser à la fin de cette procédure

end;


//test 2
//procedure creerPlateau(plateau, environnement);

//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);


end.