#!/bin/bash
# LaTeX Installation Script for GitHub Actions Self-Hosted Runner

echo "=== Installing LaTeX (TeX Live) ==="
echo "This may take several minutes..."
echo ""

# Update package manager
sudo apt-get update

# Install TeX Live with common packages
echo "Installing TeX Live..."
sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-bibtex-extra

echo ""
echo "Verifying installation..."

# Check if pdflatex is installed
if command -v pdflatex &> /dev/null; then
    echo "✓ pdflatex installed successfully"
    pdflatex --version | head -1
else
    echo "✗ Installation failed"
    exit 1
fi

# Check for auxiliary tools
echo ""
echo "Checking auxiliary tools:"
command -v bibtex &> /dev/null && echo "✓ bibtex found" || echo "⚠ bibtex not found"
command -v makeindex &> /dev/dev/null && echo "✓ makeindex found" || echo "⚠ makeindex not found"

echo ""
echo "=== LaTeX Installation Complete ==="
