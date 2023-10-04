program Cluedo;


uses unite;


procedure menu(c : Integer);

begin
    writeln('Que voulez-vous faire :');
    writeln('   1 : Lancer une partie');
    writeln('   2 : Afficher les règles du jeu');
    writeln('   3 : Quitter');
    repeat
        readln(c);
    until ((c >= 1) AND (c <= 3));
end;

var c : Integer;

begin
    menu(c);
end.
