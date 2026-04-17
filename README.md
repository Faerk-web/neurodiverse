# neurodiverse

## Anker app (Flutter + Firebase) starter structure

```text
/home/runner/work/neurodiverse/neurodiverse
├── lib
│   ├── main.dart
│   └── features
│       ├── emotions
│       │   └── emotional_thermometer.dart
│       └── timeline
│           └── visual_timeline.dart
├── functions
│   ├── index.js
│   └── package.json
└── pubspec.yaml
```

### Included in this implementation
- `main.dart` setup with role switching (`Child`, `Parent/Teacher`) and mode toggling (`ADHD`, `Autism`).
- Visual Timeline module with vertical tasks and active task visual countdown.
- Emotional Thermometer (Battery Check) logic that opens a Sensory Toolbox modal in red zone.
- Firebase Cloud Function boilerplate to push teacher schedule updates to child inbox documents.
