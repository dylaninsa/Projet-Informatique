Unit affichage;


Interface

uses unite, Crt;


procedure affiche(c : Char; posX, posY : Integer);
procedure affichage_plateau(plat : Plateau);
procedure deplacement(plat : Plateau; joueurs : ListeJoueurs);



Implementation

procedure affiche(c : Char; posX, posY : Integer);

begin
	GotoXY(posX, posY);
	write(c);
end; 



procedure affichage_plateau(plat : Plateau);

var i, j : Integer;

begin
    {Tests : Affichage de la grille (pas au bon endroit)}
    ClrScr;
	i := 1;
	j := 1;
	for i := 1 to 28 do
		for j := 1 to 28 do
			begin
				case plat.grille[j][i] of
					0 : write(' ');
					1 : write('/');
				end;
				if (j = 28) then
					writeln();
			end;
end;

    


procedure deplacement(plat : Plateau; joueurs : ListeJoueurs);

var key : Char;
	cursorX, cursorY : Integer;

begin
    {Tests : Déplacements}
    cursorX := joueurs[1].pos[1];
    cursorY := joueurs[1].pos[2];

    repeat
		begin
			affiche(joueurs[1].pion, cursorX, cursorY);
			key := readKey();
			case key of
				UP : if ((cursorY - 1 >= 2) AND (plat.grille[cursorX][cursorY - 1] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
						cursorY := cursorY - 1;
					end;
				DOWN : if ((cursorY + 1 <= 27) AND (plat.grille[cursorX][cursorY + 1] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
						cursorY := cursorY + 1;
					end;
				LEFT : if ((cursorX - 1 >= 2) AND (plat.grille[cursorX - 1][cursorY] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
						cursorX := cursorX - 1;
					end;
				RIGHT : if ((cursorX + 1 <= 27) AND (plat.grille[cursorX + 1][cursorY] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
						cursorX := cursorX + 1;
					end;
			end ;
		end;
		until (key = #113);
end;

end.