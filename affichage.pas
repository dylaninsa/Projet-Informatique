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
{Procedure permettant d'afficher un caractere aux coordonnees saisies}

begin
	TextBackground(7);  // Coloration de l'arriere plan du pointeur en gris clair
	case c of  // Instruction permettant de traiter les differents cas en fonction du caractere 'c'
		'M' : TextColor(14);  // Coloration de la police en jaune
		'P' : TextColor(1);  // Coloration de la police en bleu
		'L' : TextColor(15);  // Coloration de la police en blanc
		'O' : TextColor(2);  // Coloration de la police en vert
		'R' : TextColor(13);  // Coloration de la police en rose
		'V' : TextColor(5);  // Coloration de la police en violet
		'B' : TextColor(3);  // Coloration de la police en cyan
		'A' : TextColor(13);  // Coloration de la police en rose
		'Y' : TextColor(14);  // Coloration de la police en jaune
		'D' : TextColor(15);  // Coloration de la police en blanc
		'I' : TextColor(4);  // Coloration de la police en rouge
		'T' : TextColor(11);  // Coloration de la police en cyan clair
	end;
	GotoXY(2 * posX - 1, posY);  // Va a la position saisie
	write(c);  // Ecriture du caractere
	TextColor(15);  // Retablissement de la couleur de la police en blanc
	TextBackground(0);  // Retablissement de la couleur de l'arriere plan en noir
end; 



procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);
{Procedure affichant le plateau de jeu}

var i, j : Integer;

begin
    ClrScr;
	i := 1;  // Initialisation des coordonnees
	j := 1;
	TextColor(8);  // Coloration de la police en gris fonce
	for i := 1 to 28 do  // Boucle parcourant les lignes du plateau
		for j := 1 to 26 do  // Boucle parcourant les colonnes du plateau sur une ligne
			begin
				case plat.grille[j][i] of  // Instruction permettant de traiter les differents cas en fonction de la valeur de la case
					0 : write('  ');  // Cas d'une case sur laquelle on peut se deplacer
					1 : write('||');  // Cas d'un mur
					2 : write('#|');  // Cas d'un passage secret 1
					3 : write('@|');  // Cas d'un passage secret 2
				end;
				if (j = 26) then  // Cas de la fin d'une ligne
					writeln();  // Retour a la ligne
			end;
	

	GotoXY(4, 3);  // Deplacement jusqu'a la salle 1 
	write(ListeCartesToStr(plat.salles[1].nom));  // Ecriture du nom de la salle 1
	GotoXY(21, 5);  // Deplacement jusqu'a la salle 2 
	write(ListeCartesToStr(plat.salles[2].nom));  // Ecriture du nom de la salle 2
	GotoXY(40, 3);  // Deplacement jusqu'a la salle 3 
	write(ListeCartesToStr(plat.salles[3].nom));  // Ecriture du nom de la salle 3
	GotoXY(2, 13);  // Deplacement jusqu'a la salle 4 
	write(ListeCartesToStr(plat.salles[4].nom));  // Ecriture du nom de la salle 4
	GotoXY(42, 11);  // Deplacement jusqu'a la salle 5 
	write(ListeCartesToStr(plat.salles[5].nom));  // Ecriture du nom de la salle 5
	GotoXY(40, 19);  // Deplacement jusqu'a la salle 6 
	write(ListeCartesToStr(plat.salles[6].nom));  // Ecriture du nom de la salle 6
	GotoXY(5, 22);  // Deplacement jusqu'a la salle 7
	write(ListeCartesToStr(plat.salles[7].nom));  // Ecriture du nom de la salle 7
	GotoXY(25, 26);  // Deplacement jusqu'a la salle 8
	write(ListeCartesToStr(plat.salles[8].nom));  // Ecriture du nom de la salle 8
	GotoXY(43, 24);  // Deplacement jusqu'a la salle 9
	write(ListeCartesToStr(plat.salles[9].nom));  // Ecriture du nom de la salle 9
	GotoXY(25, 13);  // Deplacement jusqu'a la salle 10 
	write(ListeCartesToStr(plat.salles[10].nom));  // Ecriture du nom de la salle 10


	for i := 1 to length(joueurs) do  // Boucle se repetant le nombre de joueur fois
		begin
			GotoXY(2 * joueurs[i].pos[1] - 1, joueurs[i].pos[2]);  // Deplacement jusqu'a la case de la position du joueur i
			colorPerso(joueurs, i);  // Appel de la procedure colorPerso pour colorer la police en fonction du pion a ecrire
			write(joueurs[i].pion);  // Ecriture du pion du joueur i
		end;
	
	TextColor(15);  // Retablissement de la couleur de la police en noir
end;



procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);
{Procedure affanchant les cartes du joueur saisi}

var carte : ListeCartes;

begin
	write('Voici vos cartes : ');
	for carte in joueurs[j].cartes do  // Boucle se repetant le nombre de cartes du joueur j fois
		write(ListeCartesToStr(carte), ', ');  // Affichage des cartes du joueur j
	writeln();
end;



procedure affichageDeplacement(move : Integer);
{Procedure affichant le nombre de deplacements restants}

begin
	GotoXY(70, 15);  // Deplacement jusqu'a l'emplacement de l'affichage des deplacements restants
	write('Deplacements restants : ', move, ' ');  // Ecriture du nombre de deplacements restants
end;



procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; j_actif : Integer; var reveal : ListeCartes);
{Procedure demandant au joueur j quelle carte montrer au joueur 'actif'}

var continue : Char;
	ens : set of ListeCartes;
	carte : ListeCartes;
	i : Integer;
	carteStr : String;

begin
	ens := [];  // Initialisation de l'enseble des cartes en commun
	for i := 1 to length(commun) do  // Boucle parcourant les cartes de commun
		Include(ens, commun[i]);  // Inclusion des cartes de commun dans ens


	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(', c''est a vous !');  // Appel du joueur j
	writeln('(Appuyer sur ''espace'')');

	repeat  // Boucle se repetant jusqu'a ce que le joueur j appuie sur 'espace'
        continue := readKey();
        until (continue = SPACE);

	write('Voici les cartes en commun entre vos cartes et celles de l''hypothese acuelle : ');  // Affichage au joueur j les cartes en commun
	for carte in ens do  // Boucle parcourant les cartes de ens
		write(ListeCartesToStr(carte), ', ');  // Affichage des cartes de ens
	writeln();

	write('Quelle carte voulez-vous montrer ? ');  // Demande au joueur j quelle carte montrer
	repeat  // Boucle se repetant jusqu'a ce que la carte saisie soit une des cartes en commun
		readln(carteStr);
		if StrCorrect(carteStr) then  // Verification de la validite de la carte saisie
			begin
				reveal := StrToListeCartes(carteStr);
				if not(reveal in ens) then  // Verification de l'appartenence de la carte saisie aux cartes en commun
					writeln('La carte ne correspond pas aux cartes en commun.')
			end
		else
			writeln('La saisie est incorrecte.');
		until ((reveal in ens) AND StrCorrect(carteStr));
	

    ClrScr;
	colorPerso(joueurs, j_actif);
    write(ListeCartesToStr(joueurs[j_actif].perso));  // Affichage de  la carte choisie par le joueur j au joueur 'actif'
    TextColor(15);
    write(', ');
	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(' vous montre une de ses cartes. Etes-vous pret ?');
	writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle se repetant jusqu'a ce que le joueur 'actif' appuie sur 'espace'
        continue := readKey();
        until (continue = SPACE);

    write('La carte que ');  // Affichage de la carte du joueur j au joueur 'actif'
	colorPerso(joueurs, j);
    write(ListeCartesToStr(joueurs[j].perso));
    TextColor(15);
	writeln(' vous montre est : ', ListeCartesToStr(reveal), '.');
	writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle se repetant jusqu'a ce que le joueur 'actif' appuie sur 'espace'
        continue := readKey();
        until (continue = SPACE);

    ClrScr;
end;



procedure colorPerso(joueurs : ListeJoueurs; j : Integer);
{Procedure colorant la police en fonction du joueur}

begin
    case joueurs[j].perso of  // Instruction permettant de traiter les differents cas en fonction du joueur
		Colonel_Moutarde : TextColor(14);  // Coloration de la police en jaune
		Madame_Pervenche : TextColor(1);  // Coloration de la police en bleu
		Madame_Leblanc : TextColor(15);  // Coloration de la police en blanc
		Docteur_Olive : TextColor(2);  // Coloration de la police en vert
		Mademoiselle_Rose : TextColor(13);  // Coloration de la police en rose
		Professeur_Violet : TextColor(5);  // Coloration de la police en violet
		Monsieur_Bredel : TextColor(3);  // Coloration de la police en cyan
		Madame_LArcheveque : TextColor(13);  // Coloration de la police en rose
		Yohann_Lepailleur : TextColor(14);  // Coloration de la police en jaune
		Directeur : TextColor(15);  // Coloration de la police en blanc
		Infirmiere : TextColor(4);  // Coloration de la police en rouge
		Monsieur_Thibault : TextColor(11);  // Coloration de la police en cyan clair
	end;
end;



procedure affichageSortieSalle(salle : Integer);
{Procedure affichant les touches sur lesquelles appuyer pour sortir d'une salle}

begin
	TextColor(8);  // Coloration de l'arriere plan du pointeur en gris clair
	case salle of  // Instruction permettant de traiter les differents cas en fonction de la salle
		1 : begin  // Cas de la salle 1
				GotoXY(6, 7);  // Deplacement jusqu'a la sortie 1
				write('b');
				GotoXY(13, 3);  // Deplacement jusqu'a la sortie 2
				write('h');
			end;
		2 : begin  // Cas de la salle 2
				GotoXY(21, 9);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(31, 9);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
				GotoXY(19, 7);  // Deplacement jusqu'a la sortie 3
				write('g');  // Affichage de la touche pour sortir par la sortie 3
				GotoXY(33, 7);  // Deplacement jusqu'a la sortie 4
				write('d');  // Affichage de la touche pour sortir par la sortie 4
			end;
		3 : begin  // Cas de la salle 3
				GotoXY(41, 5);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(45, 3);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
			end;
		4 : begin  // Cas de la salle 4
				GotoXY(17, 14);  // Deplacement jusqu'a la sortie 1
				write('d');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(15, 17);  // Deplacement jusqu'a la sortie 2
				write('b');  // Affichage de la touche pour sortir par la sortie 2
			end;
		5 : begin  // Cas de la salle 5
				GotoXY(47, 13);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(41, 11);  // Deplacement jusqu'a la sortie 2
				write('d');  // Affichage de la touche pour sortir par la sortie 2
			end;
		6 : begin  // Cas de la salle 6
				GotoXY(40, 18);  // Deplacement jusqu'a la sortie 1
				write('d');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(43, 17);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
			end;
		7 : begin  // Cas de la salle 7
				GotoXY(9, 26);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(13, 22);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
			end;
		8 : begin  // Cas de la salle 8
				GotoXY(25, 21);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(17, 21);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
				GotoXY(30, 22);  // Deplacement jusqu'a la sortie 3
				write('d');  // Affichage de la touche pour sortir par la sortie 3
			end;
		9 : begin  // Cas de la salle 9
				GotoXY(45, 26);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
				GotoXY(39, 24);  // Deplacement jusqu'a la sortie 2
				write('h');  // Affichage de la touche pour sortir par la sortie 2
			end;
		10 : begin  // Cas de la salle 10
				GotoXY(27, 17);  // Deplacement jusqu'a la sortie 1
				write('b');  // Affichage de la touche pour sortir par la sortie 1
			end;
	end;
	TextColor(15);  // Retablissement de la couleur de la police en noir
end;


end.