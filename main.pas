program Cluedo;


uses unite, Crt, configurationPartie, partie, affichage;


procedure menu(var c : Integer);

begin
    writeln('Que voulez-vous faire :');
    writeln('   1 : Lancer une partie');
    writeln('   2 : Afficher les règles du jeu');
    writeln('   3 : Quitter');
    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 3)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 3));
end;


procedure quitter();

begin
    Halt;
end;


procedure afficherRegles();

var ligne : String;
    regles : Text;

begin
    assign(regles, 'regles.txt');
    reset(regles);
    while not(eof(regles)) do
        begin
            readln(regles, ligne);
            writeln(ligne);
        end;
    close(regles);
end;


var c : Integer;
    joueurs : ListeJoueurs;
    plat : Plateau;
    etui : Array [1..3] of ListeCartes;

begin
    ClrScr;
    menu(c);
    case c of
        1 : lancerPartie(joueurs, plat, etui);
        2 : afficherRegles();
        3 : quitter();
    end;
    Halt();
end.