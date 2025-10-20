# haumap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Documentation

See `docs/uml/architecture.md` for the architecture overview and UML. Individual Mermaid files are available for embedding or export:

- Package diagram: `docs/uml/package-diagram.mmd`
- Core models class diagram: `docs/uml/models-class-diagram.mmd`
- Services/ViewModel class diagram: `docs/uml/services-viewmodel-class-diagram.mmd`
- UI class diagram: `docs/uml/ui-class-diagram.mmd`
- Combined class diagram (all-in-one): `docs/uml/combined-class-diagram.mmd`
 - Layered architecture diagram: `docs/uml/architecture-diagram.mmd`
 - System flowchart: `docs/uml/system-flowchart.mmd`
- Sequence (user navigation): `docs/uml/sequence-user-navigation.mmd`
- Sequence (admin update): `docs/uml/sequence-admin-update.mmd`

Optional: export to PNG/SVG with Mermaid CLI (requires Node and `@mermaid-js/mermaid-cli`). On Windows PowerShell (from the repo root):

```powershell
# Install once
npm install -g @mermaid-js/mermaid-cli

# Export examples (PNG)
mmdc -i .\docs\uml\package-diagram.mmd -o .\docs\uml\package-diagram.png
mmdc -i .\docs\uml\models-class-diagram.mmd -o .\docs\uml\models-class-diagram.png
mmdc -i .\docs\uml\combined-class-diagram.mmd -o .\docs\uml\combined-class-diagram.png
mmdc -i .\docs\uml\system-flowchart.mmd -o .\docs\uml\system-flowchart.png

# Or export all diagrams at once (PNG by default)
PowerShell -ExecutionPolicy Bypass -File .\scripts\export-uml.ps1

# Crisper PNGs: increase scale and optional width, uses default Mermaid config in docs/uml/mermaid-config.json
PowerShell -ExecutionPolicy Bypass -File .\scripts\export-uml.ps1 -Scale 3 -Width 2200

# Export all diagrams as SVG
PowerShell -ExecutionPolicy Bypass -File .\scripts\export-uml.ps1 -Format svg
```
