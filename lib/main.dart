import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';

void main() {
  runApp(const MatheApp());
}

// 1. DIE KONFIGURATION
class MatheApp extends StatelessWidget {
  const MatheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mathe Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // WICHTIG: Wir starten jetzt mit dem MenuScreen, nicht mehr direkt mit der Aufgabe
      home: const MenuScreen(),
    );
  }
}

// 2. DAS MENÜ (Der neue Startbildschirm)
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Natural Maths"),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Sieht modern aus
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ein schönes Icon zur Begrüßung
            Icon(
              Icons.functions, // Ein Mathe-Symbol
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              "Dein tägliches Training",
              style: TextStyle(fontSize: 22, color: Colors.white70),
            ),
            const SizedBox(height: 60),

            // Der Button, der zur Aufgabe führt
            FilledButton.icon(
              onPressed: () {
                // HIER PASSIERT DIE NAVIGATION
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Daily Challenge", style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. DER SPIEL-SCREEN (Ehemals MatheScreen)
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String latexCode = "";
  int? richtigeLoesung;
  final Random random = Random();
  final TextEditingController _textController = TextEditingController();

  // NEU: Status-Variablen für das UI
  Color randFarbe = Colors.white12; // Standard: unauffälliges Grau
  bool aufgabeGeloest = false;      // Steuert den Button-Zustand

  @override
  void initState() {
    super.initState();
    neueMatrixGenerieren();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void neueMatrixGenerieren() {
    _textController.clear();
    
    // UI zurücksetzen
    setState(() {
      randFarbe = Colors.white12;
      aufgabeGeloest = false;
    });

    int a = random.nextInt(11) - 5;
    int b = random.nextInt(11) - 5;
    int c = random.nextInt(11) - 5;
    int d = random.nextInt(11) - 5;

    setState(() {
      richtigeLoesung = (a * d) - (b * c);
      latexCode = r"A = \begin{pmatrix}"
          "$a & $b \\\\ $c & $d"
          r"\end{pmatrix}";
    });
  }

  void antwortPruefen() {
    String eingabe = _textController.text;
    int? benutzerAntwort = int.tryParse(eingabe);

    if (benutzerAntwort == null) {
      zeigeFeedback("Bitte eine Zahl eingeben!", Colors.orange);
      return;
    }

    if (benutzerAntwort == richtigeLoesung) {
      // RICHTIG
      setState(() {
        randFarbe = Colors.greenAccent; // Rahmen wird grün
        aufgabeGeloest = true;          // Button wechselt Funktion
      });
      zeigeFeedback("Richtig! Super gemacht.", Colors.green);
      FocusScope.of(context).unfocus(); // Tastatur weg
    } else {
      // FALSCH
      setState(() {
        randFarbe = Colors.redAccent;   // Rahmen wird rot
      });
      zeigeFeedback("Falsch. Versuch es nochmal!", Colors.redAccent);
      // Wir lassen aufgabeGeloest auf false, damit man es nochmal probieren kann
    }
  }

  void zeigeFeedback(String text, Color farbe) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Alte Nachricht sofort löschen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: farbe,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Challenge"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      // 1. ZENTRIERUNG FIX
      // Center sorgt für vertikale Mitte (wenn Platz da ist)
      // Alignment.center sorgt für horizontale Mitte
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontal zentrieren
              children: [
                const Text(
                  "Berechne die Determinante:",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Math.tex(
                    latexCode,
                    textStyle: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 40),

                // EINGABEFELD mit dynamischem Rahmen
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _textController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    textAlign: TextAlign.center,
                    // Wenn gelöst, darf man nichts mehr tippen (readOnly)
                    readOnly: aufgabeGeloest, 
                    style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "?",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      // HIER ÄNDERT SICH DIE FARBE DES RAHMENS
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: randFarbe, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: randFarbe, width: 2),
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!aufgabeGeloest) antwortPruefen();
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // DER INTELLIGENTE BUTTON
                FilledButton(
                  // Wenn gelöst -> Neue Aufgabe, Sonst -> Prüfen
                  onPressed: aufgabeGeloest ? neueMatrixGenerieren : antwortPruefen,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    // Farbe ändert sich auch: Grün wenn fertig, sonst Primärfarbe
                    backgroundColor: aufgabeGeloest 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    // Text ändert sich
                    aufgabeGeloest ? "Nächste Aufgabe" : "Prüfen",
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                // Überspringen nur anzeigen, wenn noch NICHT gelöst
                if (!aufgabeGeloest)
                  TextButton(
                    onPressed: neueMatrixGenerieren,
                    child: const Text("Überspringen",
                        style: TextStyle(color: Colors.white54)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}