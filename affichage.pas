Unit affichage;


Interface

uses unite, Crt;


procedure affiche(c : Char; posX, posY : Integer);
procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);
procedure affichageDes(de1 : Integer; de2 : Integer);
procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);
procedure affichageDeplacement(move : Integer);
procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; var reveal : ListeCartes);



Implementation

procedure affiche(c : Char; posX, posY : Integer);

begin
	{Affiche le caractère 'c' à l'emplacement posX posY}
	GotoXY(posX, posY);
	write(c);
end; 



procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);

var i, j : Integer;

begin
    {Affichage du plateau}
    ClrScr;
	i := 1;
	j := 1;
	for i := 1 to 27 do
		for j := 1 to 26 do
			begin
				case plat.grille[j][i] of
					0 : write(' ');
					1 : write('/');
				end;
				if (j = 26) then
					writeln();
			end;

	{Affichage des pions des joueurs sur le plateau}
	for i := 1 to length(joueurs) do
		begin
			GotoXY(joueurs[i].pos[1], joueurs[i].pos[2]);
			write(joueurs[i].pion);
		end;
end;

    

procedure affichageDes(de1 : Integer; de2 : Integer);

begin
	{Affiche la valeur des deux dés ainsi que le nombre de déplacements total}
	writeln('Le premier dé a pour valeur ', de1, ' et le second ', de2, '. Le nombre de déplacement total est donc de ', de1+de2, '.');
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
	GotoXY(35, 15);
	write('Déplacements restants : ', move, ' ');
end;



procedure affichageMontrerCartes(var commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; var reveal : ListeCartes);

var I : Integer;
	continue : Char;

begin
	{Montre les cartes en commun entre le joueur j et l'hypothèse formulée pendant le tour}
	writeln(joueurs[j].perso, ', c''est à vous !');

	repeat
        continue := readKey();
        until (continue = #32);

	write('Voici les cartes en commun entre vos cartes et celles de l''hypothèse acuelle : ');
	for i := 1 to length(commun) do
		write(commun[i], ' ');
	writeln();
	write('Quelle carte voulez-vous montrer ? ');
	readln(reveal);
end;


end.