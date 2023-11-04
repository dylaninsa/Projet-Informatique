Unit affichage;


Interface

uses unite, Crt;


procedure affiche(c : Char; posX, posY : Integer);
procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);
procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);
procedure affichageDeplacement(move : Integer);
procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; j_actif : Integer; var reveal : ListeCartes);
procedure colorPerso(joueurs : ListeJoueurs; j : Integer);



Implementation

procedure affiche(c : Char; posX, posY : Integer);

begin
	{Affiche le caractère 'c' à l'emplacement posX posY}
	TextBackground(7);
	case c of
		'M' : TextColor(14);
		'P' : TextColor(1);
		'L' : TextColor(15);
		'O' : TextColor(2);
		'R' : TextColor(13);
		'V' : TextColor(5);
		'B' : TextColor(3);
		'A' : TextColor(13);
		'Y' : TextColor(14);
		'D' : TextColor(15);
		'I' : TextColor(4);
		'T' : TextColor(11);
	else
		TextBackground(0);
	end;
	GotoXY(posX + (posX - 1), posY);
	write(c);
	TextColor(15);
	TextBackground(0);
end; 



procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);

var i, j : Integer;

begin
    {Affichage du plateau}
    ClrScr;
	i := 1;
	j := 1;
	TextColor(8);
	for i := 1 to 27 do
		for j := 1 to 26 do
			begin
				case plat.grille[j][i] of
					0 : write('  ');
					1 : write('||');
				end;
				if (j = 26) then
					writeln();
			end;
	

	{Affichage du nom des salles}
	GotoXY(4, 3);
	write(plat.salles[1].nom);
	GotoXY(21, 5);
	write(plat.salles[2].nom);
	GotoXY(40, 3);
	write(plat.salles[3].nom);
	GotoXY(2, 13);
	write(plat.salles[4].nom);
	GotoXY(42, 11);
	write(plat.salles[5].nom);
	GotoXY(40, 19);
	write(plat.salles[6].nom);
	GotoXY(5, 22);
	write(plat.salles[7].nom);
	GotoXY(25, 26);
	write(plat.salles[8].nom);
	GotoXY(43, 24);
	write(plat.salles[9].nom);
	GotoXY(25, 13);
	write(plat.salles[10].nom);


	{Affichage des pions des joueurs sur le plateau}
	for i := 1 to length(joueurs) do
		begin
			GotoXY(joueurs[i].pos[1] + (joueurs[i].pos[1] - 1), joueurs[i].pos[2]);
			case joueurs[i].perso of
				Colonel_Moutarde : TextColor(14);
				Madame_Pervenche : TextColor(1);
				Madame_Leblanc : TextColor(15);
				Docteur_Olive : TextColor(2);
				Mademoiselle_Rose : TextColor(13);
				Professeur_Violet : TextColor(5);
				Monsieur_Bredel : TextColor(3);
				Madame_LArcheveque : TextColor(13);
				Yohann_Lepailleur : TextColor(14);
				Le_Directeur : TextColor(15);
				Infirmiere : TextColor(4);
				Monsieur_Thibault : TextColor(11);
			end;
			write(joueurs[i].pion);
		end;


	{Affichage des passages secrets}
	TextColor(8);
	GotoXY(7, 2);
	write('#');
	GotoXY(45, 27);
	write('#');
	GotoXY(45, 2);
	write('@');
	GotoXY(9, 27);
	write('@');
	TextColor(15);
end;



procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);

var carte : ListeCartes;

begin
	{Affiche les carte du joueur j}
	write('Voici vos cartes : ');
	for carte in joueurs[j].cartes do
		write(carte, ' ');
	writeln();
end;



procedure affichageDeplacement(move : Integer);

begin
	{Affiche le nombre de déplacements restant}
	GotoXY(70, 15);
	write('Deplacements restants : ', move, ' ');
end;



procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; j_actif : Integer; var reveal : ListeCartes);

var continue : Char;
	ens : set of ListeCartes;
	carte : ListeCartes;
	i : Integer;

begin
	{Délcaration et implémentation des cartes en commun dans un ensemble}
	ens := [];
	for i := 1 to length(commun) do
		Include(ens, commun[i]);


	{Montre les cartes en commun entre le joueur j et l'hypothèse formulée pendant le tour et lui demande quelle carte montrer}
	colorPerso(joueurs, j);
    write(joueurs[j].perso);
    TextColor(15);
	writeln(', c''est a vous !');

	repeat
        continue := readKey();
        until (continue = #32);

	write('Voici les cartes en commun entre vos cartes et celles de l''hypothese acuelle : ');
	for carte in ens do
		write(carte, ' ');
	writeln();

	repeat
        write('Quelle carte voulez-vous montrer ? ');
		readln(reveal);
        if not(reveal in ens) then
            writeln('La carte ne correspond pas aux cartes en commun.')
        until (reveal in ens);
	

	{Montre la carte choisie par j au j_actif}
    ClrScr;
	colorPerso(joueurs, j_actif);
    write(joueurs[j_actif].perso);
    TextColor(15);
    write(', ');
	colorPerso(joueurs, j);
    write(joueurs[j].perso);
    TextColor(15);
	writeln(' vous montre une de ses cartes. Êtes-vous pret ?  (Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = #32);

    write('La carte que ');
	colorPerso(joueurs, j);
    write(joueurs[j].perso);
    TextColor(15);
	writeln(' vous montre est : ', reveal, ' (Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = #32);

    ClrScr;
end;



procedure colorPerso(joueurs : ListeJoueurs; j : Integer);

begin
    case joueurs[j].perso of
		Colonel_Moutarde : TextColor(14);
		Madame_Pervenche : TextColor(1);
		Madame_Leblanc : TextColor(15);
		Docteur_Olive : TextColor(2);
		Mademoiselle_Rose : TextColor(13);
		Professeur_Violet : TextColor(5);
		Monsieur_Bredel : TextColor(3);
		Madame_LArcheveque : TextColor(13);
		Yohann_Lepailleur : TextColor(14);
		Le_Directeur : TextColor(15);
		Infirmiere : TextColor(4);
		Monsieur_Thibault : TextColor(11);
	end;
end;


end.