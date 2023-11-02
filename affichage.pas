Unit affichage;


Interface

uses unite, Crt;


procedure affiche(c : Char; posX, posY : Integer);
procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);
procedure affichageDes(de1 : Integer; de2 : Integer);
procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);
procedure affichageDeplacement(move : Integer);
procedure affichageMontrerCartes(commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; var reveal : ListeCartes);



Implementation

procedure affiche(c : Char; posX, posY : Integer);

begin
	GotoXY(posX, posY);
	write(c);
end; 



procedure affichagePlateau(plat : Plateau; joueurs : ListeJoueurs);

var i, j : Integer;

begin
    {Tests : Affichage de la grille (pas au bon endroit)}
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


	for i := 1 to length(joueurs) do
		begin
			GotoXY(joueurs[i].pos[1], joueurs[i].pos[2]);
			write(joueurs[i].pion);
		end;
end;

    

procedure affichageDes(de1 : Integer; de2 : Integer);

begin
	writeln('Le premier dé a pour valeur ', de1, ' et le second ', de2, '. Le nombre de déplacement total est donc de ', de1+de2, '.');
end;



procedure affichageCartes(joueurs : ListeJoueurs; j : Integer);

var carte : ListeCartes;

begin
	write('Voici vos cartes : ');
	for carte in joueurs[j].cartes do
		write(carte, ' ');
	writeln();
end;



procedure affichageDeplacement(move : Integer);

begin
	GotoXY(35, 15);
	write('                              ');
	write('Déplacements restants : ', move);
end;



procedure affichageMontrerCartes(commun : Array of ListeCartes; joueurs : ListeJoueurs; j : Integer; var reveal : ListeCartes);

var carte : ListeCartes;

begin
	writeln(joueurs[j].perso, ', c''est à vous !');

	write('Voici les cartes en commun entre vos cartes et celles de l''hypothèse acuelle : ');
	for carte in commun do
		write(carte, ' ');
	writeln();
	write('Quelle carte voulez-vous montrer ? ');
	readln(reveal);
end;


end.