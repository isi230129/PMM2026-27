# Aufgabe KM7-01 — Mittelwertsvergleich: z-Test und t-Test

Name: _Eda Isik_ &nbsp;&nbsp;&nbsp; Abgabe: ____17.11.12026_________

**Lektüre:** Navarro, [Learning Statistics with R](https://learningstatisticswithr.com/13-ttest.html)
(Pflicht) — **Kap. 13, t-Tests**. Die Fragen in Aufgabe 4 beziehen sich auf
das Kapitel. Ergänzend NIST/SEMATECH e-Handbook, Kap. 7.

**Daten:** `assets/betriebsdaten.csv` — 120 Messungen, 3 Maschinen (M1–M3) ×
10 Chargen × 4 Teile, Sollmaß 10,00 mm, Toleranz ± 0,15 mm. Vier Messungen
fehlen (M1: drei, M2: eine).

> **Setup-Ritual:** Lege ein RStudio-Projekt `pmm-km7-01` an, speichere
> alles in `analyse.R` dort. Daten laden mit
> `read_csv(".../assets/betriebsdaten.csv")`.

---

## 1. Vorhersagen (ohne R — erst hinschreiben!)

**a)** Wie viele gültige Messungen hat jede Maschine?

```r
daten |> group_by(maschine) |>
  summarise(n = sum(!is.na(masse_mm)))
```

Vorhersage: M1:37,M2:39,M3:40

**b)** Welche Maschine hat den größten Abstand zwischen Mittelwert und
Sollmaß 10,00 mm? Um wie viele Hundertstel?

Vorhersage: _M3,ca 5 Hundertsel___________________

**c)** M1 und M2 unterscheiden sich um 0,024 mm im Mittelwert, die
Streuungen sind 0,032 mm und 0,040 mm. M1 und M3 unterscheiden sich um
0,062 mm bei 0,032 mm und 0,070 mm Streuung. **Welcher Vergleich fällt
statistisch leichter durch — und warum?** (2 Sätze, ohne Formel)

_M1 vs. M3 fällt statistisch leichter durch. Der Mittelwertunterschied (0,062 mm) ist mehr als doppelt so groß wie bei M1 vs. M2 (0,024 mm), und die größere Streuung von M3 wiegt das nur teilweise auf.
__M1 vs. M3 fällt statistisch leichter durch. Der Mittelwertunterschied (0,062 mm) ist mehr als doppelt so groß wie bei M1 vs. M2 (0,024 mm), und die größere Streuung von M3 wiegt das nur teilweise auf.______________________________________________

---

## 2. Der ungepaarte Vergleich

Vergleiche **M1 gegen M3** mit dem Welch-t-Test. Schreibe die beiden
Hypothesen auf, die getestet werden:

- H0: __μ(M1) = μ(M3)_______________________________________________
- H1: __μ(M1) ≠ μ(M3)_______________________________________________

```r
vergleich <- daten |> filter(maschine %in% c("M1", "M3"))
t.test(masse_mm ~ maschine, data = vergleich)
```

- t-Wert: __ca. −5,1__ &nbsp; Freiheitsgrade: _ca.55___________
- p-Wert: 4.092e-06____<0,0001________
- 95-%-Konfidenzintervall der Differenz: _-0.08658875 -0.03783017___________________

**Lies das Intervall in ganzen Sätzen.** M3 liegt um wie viele mm
*mindestens* über M1 — und um wie viele mm *höchstens*? Vergleiche mit der
Toleranz von ± 0,15 mm: Passt der gesamte Intervall in die Toleranz, oder
ragt er hinaus?

M3 liegt mindestens ca. 0,04 mm und höchstens ca. 0,09 mm über M1. Das ganze Intervall liegt innerhalb der Toleranz von ± 0,15 mm._________________________________________________

---

## 3. Der gepaarte Vergleich

M3 und M1 fertigen dieselben 10 Chargen. Baue die Chargenmittel und teste
**gepaart**:

```r
chargen <- daten |>
  group_by(maschine, charge) |>
  summarise(mm = mean(masse_mm, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = maschine, values_from = mm)

chargen$M3 - chargen$M1
```

**a)** Wie viele der 10 Differenzen sind positiv? _alle positiv___________
Wie viele sind negativ? _keines negativ___________

**b)**

```r
t.test(chargen$M3, chargen$M1, paired = TRUE)
```

- t-Wert: __5.9822__________ &nbsp; Freiheitsgrade: __9__________
- p-Wert: 0.000207____________

**c)** Warum hat der gepaarte Test hier **9** Freiheitsgrade, obwohl
er mit den Daten von 37 bzw. 40 Messungen arbeitet? (2 Sätze)

_Der gepaarte Test rechnet nur mit den 10 Chargen-Differenzen, nicht mit den einzelnen Messungen. Daher gilt df = n − 1 = 9.________________________________________________

**d)** Rechne den t-Wert von Hand nach — einmal über die **Differenzen**,
einmal über die **Messwerte** mit den Mittelwerten aus Aufgabe 1:

- t über die Differenzen: t = d̄ / (s_d / √10)
- t über die Messwerte (Mittelwert-Differenz / Streuung): __ca.5,1__________

Welcher Wert stimmt mit R überein, und was lernst du daraus über die
gepaarte Formel?

Die gepaarte Formel nutzt nur die Streuung der Differenzen, nicht die der Rohwerte, und ist deshalb bei zusammengehörigen Werten empfindlicher._________________________________________________

---

## 4. Kapitel-Check (Navarro Kap. 13)

**a)** Erkläre in 2–3 Sätzen, warum man einen t-Test verwendet, wenn &sigma;
der Grundgesamtheit *nicht* bekannt ist. Was macht der t-Test mit dem
geschätzten &sigma;, das der z-Test nicht macht?

Weil σ unbekannt ist, wird es durch die Stichproben-Streuung s geschätzt. Der t-Test berücksichtigt diese Unsicherheit durch die t-Verteilung mit breiteren Rändern, der z-Test tut so, als wäre σ exakt bekannt._________________________________________________

**b)** Ein Kollege sagt nach einem Test mit `p = 0,42`: „Die beiden
Maschinen sind also gleich gut." Hat er recht? Begründe mit dem Konzept
der Fehler 1. und 2. Art.

Nein. p = 0,42 zeigt nur, dass kein Unterschied nachgewiesen wurde, nicht dass keiner existiert. Es kann ein Fehler 2. Art vorliegen, also ein übersehener echter Unterschied, etwa bei kleinem n oder großer Streuung._________________________________________________

**c)** Nenne drei Situationen aus der Fertigung, in denen ein **gepaarter**
t-Test der richtige ist, und jeweils einen Grund, warum die Werte
paarweise zusammengehören.

1. Dasselbe Werkstück vor und nach der Wärmebehandlung messen_________________________________________________
2. Dieselben Teile mit zwei Messgeräten messen._________________________________________________
3. Dieselben Chargen auf zwei Maschinen fertigen._________________________________________________

---

## 5. Die Frage hinter der Aufgabe

M1 und M2 sind sich im Mittel um 0,024 mm unterschiedlich — der
ungepaarte Test liefert `p = 0,005456`, also „signifikant".

**a)** Wäre das eine Basis für eine Prozessänderung? Begründe in 3 Sätzen,
wobei du die Toleranz von ± 0,15 mm und den Sinn von `p` einbeziehst.

Nein, nicht automatisch. p = 0,005 sagt nur, dass der Unterschied wahrscheinlich nicht zufällig ist. Mit 0,024 mm entspricht er nur etwa 16 % der Toleranz von ± 0,15 mm, und ob sich eine Prozessänderung lohnt, sagt p nicht aus._________________________________________________

**b)** Erkläre den Unterschied zwischen diesen zwei Sätzen:

- „M1 und M2 unterscheiden sich signifikant."
- „M1 und M2 unterscheiden sich *wirtschaftlich* nicht relevant."

Warum sind das zwei verschiedene Aussagen? Welche ist die Stärke des
Tests, welche seine Grenze?

„Signifikant" heißt, dass der Unterschied statistisch kaum Zufall ist. „Wirtschaftlich nicht relevant" heißt, dass er zu klein ist, um etwas zu bewirken. Die Stärke des Tests ist, echte Effekte von Rauschen zu trennen, seine Grenze ist, dass er nichts über die Größe oder Bedeutung des Effekts sagt._________________________________________________

**c)** Wenn du der 0,024-mm-Unterschied *doch* statistisch belegen
musst: Welche Stichprobengröße bräuchtest du ungefähr, statt der 40 pro
Maschine? Du musst nicht selbst rechnen — begründe die Richtung:
mehrt man die Zahl der Teile oder die Zahl der Chargen, und warum ist
eine davon wirksamer?

Man braucht deutlich mehr Messungen, weil ein kleiner Unterschied bei gleicher Streuung nur mit größerem n sichtbar wird. Mehr Chargen sind wirksamer als mehr Teile, weil Teile innerhalb einer Charge einander ähnlich sind und wenig neue Information liefern._________________________________________________
