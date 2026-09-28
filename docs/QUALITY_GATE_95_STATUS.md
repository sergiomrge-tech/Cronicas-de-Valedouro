# QUALITY GATE 95 — Status operacional

A meta de 95% se refere ao **primeiro Vertical Slice de REG_001**, não ao RPG completo de oito regiões.

O CI executa Godot 4.7.2 oficial e valida:
- parser/import;
- validação estática;
- rotas e colisões;
- animações;
- loot/inventário/equipamento;
- Playable Gate completo;
- dois padrões do Guardião;
- controles touch;
- auditoria visual de 20 estados.

O slice só deve receber o rótulo **CANDIDATO JOGÁVEL 95** quando o workflow atual estiver verde e as 20 capturas reais forem revisadas sem placeholder gritante.
