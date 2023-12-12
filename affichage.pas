Unit affichage;


Interface


uses unite, Crt;


procedure affiche(c : Char; posX, posY : Integer);
procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);
procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);
procedure affichageDeplacement(move : Integer);
procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; j_actif : Integer; var reveal : ListeCartes);
procedure colorPerso(joueurs : ListeJoueurs; j : Integer);
procedure affichageSortieSalle(salle : Integer);



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
	GotoXY(2 * posX - 1, posY);
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
	for i := 1 to 28 do
		for j := 1 to 26 do
			begin
				case plat.grille[j][i] of
					0 : write('  ');
					1 : write('||');
					2 : write('#|');
					3 : write('@|');
				end;
				if (j = 26) then
					writeln();
			end;
	

	{Affichage du nom des salles}
	GotoXY(4, 3);
	write(ListeCartesToStr(plat.salles[1].nom));
	GotoXY(21, 5);
	write(ListeCartesToStr(plat.salles[2].nom));
	GotoXY(40, 3);
	write(ListeCartesToStr(plat.salles[3].nom));
	GotoXY(2, 13);
	write(ListeCartesToStr(plat.salles[4].nom));
	GotoXY(42, 11);
	write(ListeCartesToStr(plat.salles[5].nom));
	GotoXY(40, 19);
	write(ListeCartesToStr(plat.salles[6].nom));
	GotoXY(5, 22);
	write(ListeCartesToStr(plat.salles[7].nom));
	GotoXY(25, 26);
	write(ListeCartesToStr(plat.salles[8].nom));
	GotoXY(43, 24);
	write(ListeCartesToStr(plat.salles[9].nom));
	GotoXY(25, 13);
	write(ListeCartesToStr(plat.salles[10].nom));


	{Affichage des pions des joueurs sur le plateau}
	for i := 1 to length(joueurs) do
		begin
			GotoXY(2 * joueurs[i].pos[1] - 1, joueurs[i].pos[2]);
			colorPerso(joueurs, i);
			write(joueurs[i].pion);
		end;
	
	TextColor(15);
end;



procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);

var carte : ListeCartes;

begin
	{Affiche les carte du joueur j}
	write('Voici vos cartes : ');
	for carte in joueurs[j].cartes do
		write(ListeCartesToStr(carte), ', ');
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
	carteStr : String;

begin
	{Délcaration et implémentation des cartes en commun dans un ensemble}
	ens := [];
	for i := 1 to length(commun) do
		Include(ens, commun[i]);


	{Montre les cartes en commun entre le joueur j et l'hypothèse formulée pendant le tour et lui demande quelle carte montrer}
	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(', c''est a vous !');
	writeln('(Appuyer sur ''espace'')');

	repeat
        continue := readKey();
        until (continue = SPACE);

	write('Voici les cartes en commun entre vos cartes et celles de l''hypothese acuelle : ');
	for carte in ens do
		write(ListeCartesToStr(carte), ', ');
	writeln();

	repeat
        write('Quelle carte voulez-vous montrer ? ');
		readln(carteStr);
		if StrCorrect(carteStr) then
			begin
				reveal := StrToListeCartes(carteStr);
				if not(reveal in ens) then
					writeln('La carte ne correspond pas aux cartes en commun.')
			end
		else
			writeln('La saisie est incorrecte.');
		until ((reveal in ens) AND StrCorrect(carteStr));
	

	{Montre la carte choisie par j au j_actif}
    ClrScr;
	colorPerso(joueurs, j_actif);
    write(ListeCartesToStr(joueurs[j_actif].perso));
    TextColor(15);
    write(', ');
	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(' vous montre une de ses cartes. Etes-vous pret ?');
	writeln('(Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = SPACE);

    write('La carte que ');
	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(' vous montre est : ', ListeCartesToStr(reveal));
	writeln('(Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = SPACE);

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
		Directeur : TextColor(15);
		Infirmiere : TextColor(4);
		Monsieur_Thibault : TextColor(11);
	end;
end;



procedure affichageSortieSalle(salle : Integer);

begin
	TextBackground(8);
	case salle of 
		1 : begin
				GotoXY(6, 7);
				write('b');
				GotoXY(13, 3);
				write('h');
			end;
		2 : begin
				GotoXY(21, 9);
				write('b');
				GotoXY(31, 9);
				write('h');
				GotoXY(19, 7);
				write('g');
				GotoXY(33, 7);
				write('d');
			end;
		3 : begin
				GotoXY(41, 5);
				write('b');
				GotoXY(45, 3);
				write('h');
			end;
		4 : begin
				GotoXY(17, 14);
				write('d');
				GotoXY(15, 17);
				write('b');
			end;
		5 : begin
				GotoXY(47, 13);
				write('b');
				GotoXY(41, 11);
				write('d');
			end;
		6 : begin
				GotoXY(40, 18);
				write('d');
				GotoXY(43, 17);
				write('h');
			end;
		7 : begin
				GotoXY(9, 26);
				write('b');
				GotoXY(13, 22);
				write('h');
			end;
		8 : begin
				GotoXY(25, 21);
				write('b');
				GotoXY(17, 21);
				write('h');
				GotoXY(30, 22);
				write('d');
			end;
		9 : begin
				GotoXY(45, 26);
				write('b');
				GotoXY(39, 24);
				write('h');
			end;
		10 : begin
				GotoXY(27, 17);
				write('b');
			end;
	end;
	TextColor(15);
end;


end.