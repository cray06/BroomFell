# 🧹 BroomFell

**BroomFell** est un roguelike d'action en vue de dessus, pour mobile et PC. Tu incarnes une sorcière dans une arène envahie de slimes : tu te déplaces, elle tire toute seule, et à chaque niveau tu choisis un nouveau sort ou une amélioration. L'objectif est de survivre le plus longtemps possible et de battre ton meilleur score.

Le jeu est fait avec **Godot 4.7** (GDScript), en format portrait (720×1280).

## 🎮 Comment jouer

- **Déplacement** : joystick tactile sur mobile, ou `ZQSD` / `WASD` / flèches sur PC.
- **Attaque** : la sorcière tire automatiquement des projectiles magiques dans la direction où elle regarde.
- **Expérience** : les monstres vaincus lâchent des orbes d'XP. Ramasse-les pour monter de niveau.
- **Montée de niveau** : choisis une carte parmi plusieurs propositions (nouveau sort, niveau supérieur d'un sort, augment, ou soin).
- **Vagues** : la difficulté augmente avec le temps, des hordes arrivent régulièrement et le **Roi Slime** apparaît quand ton score atteint certains paliers.
- **Score** : ton meilleur score est sauvegardé localement.

## ✨ Sorts

Jusqu'à **3 sorts** en même temps, chacun avec 5 niveaux.

| Sort | Effet |
|---|---|
| Orbes de feu | Des boules de feu tournent autour de toi |
| Éclair en chaîne | Foudroie un monstre puis rebondit sur d'autres |
| Onde arcanique | Une onde blesse et repousse les monstres proches |
| Météores | Des météores s'écrasent sur les monstres |
| Balais volants | Des balais partent et reviennent comme des boomerangs |
| Nova de givre | Gèle les monstres autour de toi |
| Hibou familier | Un hibou t'accompagne et tire des plumes magiques |
| Tornade | Une tornade aspire et blesse les monstres |
| Traînée toxique | Tu laisses des flaques de poison derrière toi |
| Faisceau | Un rayon magique tourne autour de toi |
| Bulles | Des bulles rebondissent sur les murs et traversent les monstres |

## 🔮 Augments

Jusqu'à **3 augments** pour améliorer la sorcière : Multi-tir, Critique, Cadence, Puissance, Perforation, Ricochet, Tir arrière, Vitesse, Vitalité, Régénération, Vampirisme, Concentration, Bouclier et Aimant.

## 🎨 Direction artistique

Cartoon fantasy coloré et cosy : formes arrondies, contours foncés, ombrage simple et effets magiques lumineux, pensé pour rester lisible sur petit écran. Tous les détails sont dans [ART_DIRECTION.md](ART_DIRECTION.md).

## 🛠️ Lancer le projet

1. Installer [Godot 4.7](https://godotengine.org/download) (version standard, pas besoin de .NET).
2. Ouvrir Godot, cliquer sur **Importer** et choisir le fichier `project.godot`.
3. Lancer avec `F5`. La scène de départ est le menu principal (`scenes/menu/main_menu.tscn`).

## 📱 APK Android

Un workflow GitHub Actions ([.github/workflows/android.yml](.github/workflows/android.yml)) construit une APK à chaque push sur `main` (ou à la main depuis l'onglet **Actions** → **Build Android APK** → **Run workflow**).

**Télécharger la dernière APK (marche depuis le téléphone) :**
https://github.com/cray06/BroomFell/releases/download/latest/BroomFell.apk

Elle est aussi visible dans la page [Releases](https://github.com/cray06/BroomFell/releases/tag/latest), et en `.zip` dans les **Artifacts** de chaque run de l'onglet **Actions**.

L'APK est une version *debug*, signée avec une clé générée à chaque build. Elle s'installe directement sur un téléphone (autoriser les sources inconnues), mais il faut désinstaller l'ancienne version avant d'installer une nouvelle. Pour une publication sur le Play Store, il faudra une clé de release.

## 📂 Structure

```
assets/     polices et sprites (SVG)
scenes/
  arena/      arène et obstacles
  enemies/    slimes et boss
  main/       scène de jeu, vagues, caméra, sauvegarde
  menu/       menu principal
  player/     la sorcière et ses stats
  spells/     sorts, augments et livre de sorts
  ui/         HUD, barres, cartes de montée de niveau, joystick
  effects/    effets visuels et shaders
```

## 📜 Licences

La police [Fredoka](assets/fonts/) est sous licence SIL Open Font License (voir `assets/fonts/OFL.txt`).
