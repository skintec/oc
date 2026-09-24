#!/bin/bash
# ============================================================
#  Deploy del Cotizador Skintec a GitHub Pages
#  Repo: https://github.com/javimolin-rgb/cotizadorskintec
#  Uso: doble clic en este archivo (o "bash deploy.command")
# ============================================================
set -e
cd "$(dirname "$0")"

REPO_URL="https://github.com/javimolin-rgb/cotizadorskintec.git"
BRANCH="main"

echo "→ Carpeta de trabajo: $(pwd)"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ No encontré 'git' instalado en este computador."
  echo "   Instálalo desde https://git-scm.com/downloads y vuelve a intentar."
  read -p "Presiona Enter para cerrar..."
  exit 1
fi

if [ ! -d ".git" ]; then
  echo "→ Primera vez aquí: inicializando repositorio local..."
  git init -q
  git branch -M "$BRANCH"
  git remote add origin "$REPO_URL"
else
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "$REPO_URL"
  fi
fi

git add -A

if git diff --cached --quiet; then
  echo "→ No hay cambios nuevos que subir. El cotizador ya está al día."
else
  git commit -q -m "Actualización cotizador $(date '+%Y-%m-%d %H:%M')"
  echo "→ Cambios registrados."
fi

echo "→ Subiendo a GitHub (puede pedirte tu usuario y contraseña/token de GitHub)..."

# Intento normal de push
if git push -u origin "$BRANCH" 2>/tmp/skintec_push_err.log; then
  PUSH_OK=1
else
  PUSH_OK=0
fi

if [ "$PUSH_OK" = "0" ]; then
  echo "→ El repositorio remoto tiene historial propio. Intentando combinarlo..."
  if git pull origin "$BRANCH" --allow-unrelated-histories --no-edit 2>/tmp/skintec_pull_err.log; then
    git push -u origin "$BRANCH"
  else
    echo ""
    echo "❌ No pude subir los cambios automáticamente."
    echo "   Motivo probable (puede ser que el repositorio 'cotizadorskintec' aún no exista en GitHub):"
    echo "   ---------------------------------------------------------------"
    cat /tmp/skintec_push_err.log 2>/dev/null
    cat /tmp/skintec_pull_err.log 2>/dev/null
    echo "   ---------------------------------------------------------------"
    echo ""
    echo "   Si el repositorio no existe todavía, créalo (vacío, SIN README) en:"
    echo "   https://github.com/new  →  nombre: cotizadorskintec"
    echo "   y vuelve a ejecutar este archivo."
    read -p "Presiona Enter para cerrar..."
    exit 1
  fi
fi

echo ""
echo "✅ ¡Listo! Cotizador subido a GitHub."
echo ""
echo "Si es la PRIMERA vez que publicas este repo, activa GitHub Pages una sola vez:"
echo "  1) Ve a: https://github.com/javimolin-rgb/cotizadorskintec/settings/pages"
echo "  2) En 'Branch' elige: main  /  (root)  y guarda."
echo ""
echo "Tu cotizador quedará disponible en (puede tardar 1-2 minutos la primera vez):"
echo "  https://javimolin-rgb.github.io/cotizadorskintec/"
echo ""
read -p "Presiona Enter para cerrar..."
