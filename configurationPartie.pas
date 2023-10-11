Unit configurationPartie;

Interface

uses unite;


procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:ListeCartes);
//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);
procedure nouvellePartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:ListeCartes);
//procedure creerPlateau(var plateau:Plateau; environnement:Enviro);


Implementation


procedure lancerPartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:ListeCartes);

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


procedure nouvellePartie(var joueurs:ListeJoueurs; var plat:Plateau; var etui:ListeCartes);

var environnement : Enviro;
    nb_j, i, c : Integer;
    cartes : set of ListeCartes;
    carte : ListeCartes;
    personnages : set of Persos;
    personnage, p : Persos;

begin
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
        1 : begin
                environnement := Manoir;
                //creerPlateau(plateau, environnement);
            end;
        2 : begin
                environnement := INSA;
                //creerPlateau(plateau, environnement);
            end;
    end;

    cartes := [];
    
    personnages := [];
    
    if (environnement = Manoir) then
        begin
            for carte := Colonel_Moutarde to Hall do Include (cartes, carte);
            for personnage := Moutarde to Leblanc do Include (personnages, personnage);
        end;
    //else
    //    begin
    //        for carte := Colonel_Moutarde to Hall do Include (cartes, carte);
    //        for personnage := Moutarde to Leblanc do Include (personnages, personnage);
    //    end;
    for carte in cartes do write(carte);
    writeln('Combien y a-t-il de joueurs ?');
    readln(nb_j);
    SetLength(joueurs, nb_j-1);

    for i := 1 to nb_j do
        begin
            writeln('Quel est le personnage du jour ', i, ' ?');
            repeat
                readln(p);
                if not(p in personnages) then
                    writeln('Ce choix n''est pas disponible.')
            until (p in personnages);
            joueurs[i].perso := p;
            Exclude(personnages, joueurs[i].perso);
            joueurs[i].enVie := True;
        end;

end;



//procedure creerPlateau(plateau, environnement);

//procedure chargerPartie(var joueurs:ListeJoueurs; var plateau:Plateau; var etui:ListeCartes);


end.
