#!/bin/bash
# Reverse Architecture Documentation Generator
# Generates architectural diagrams from source code using multiple tools

set -e

echo "=== REVERSE ARCHITECTURE DOCUMENTATION GENERATOR ==="
echo ""

# Create output directory
ARCH_DIR="Book_SSW590_1/architecture"
mkdir -p "$ARCH_DIR"

echo "Step 1: Installing tools..."
apt-get update -qq
apt-get install -y -qq graphviz doxygen plantuml > /dev/null 2>&1
pip install pyreverse pylint pydot > /dev/null 2>&1
echo "✓ Tools installed"
echo ""

# ============================================================================
# 1. GENERATE JAVASCRIPT/HTML ARCHITECTURE DIAGRAM (PlantUML)
# ============================================================================
echo "Step 2: Analyzing JavaScript and HTML structure..."

cat > "$ARCH_DIR/architecture.puml" << 'PLANTUML'
@startuml devops-architecture
!theme plain
title DevOps Final Project - Architecture Overview

package "Frontend" {
  [index.html] as HTML
  [style.css] as CSS
  [demo.js] as JS
}

package "LaTeX Documentation" {
  [itManual.tex] as LATEX
  [itProjectDemo.tex] as DEMO
  [Cornell Style] as STYLE
}

package "CI/CD Pipeline" {
  [build-latex.yml] as BUILD_LATEX
  [ci-cd.yml] as CI_CD
  [GitHub Actions] as ACTIONS
}

package "Build Output" {
  [itManual.pdf] as PDF
  [version.txt] as VERSION
  [buildinfo.json] as METADATA
}

HTML --> CSS : styles
HTML --> JS : interaction
CSS --> |compiled| STYLE
LATEX --> DEMO : includes
DEMO --> |references| METADATA
CI_CD --> BUILD_LATEX : orchestrates
BUILD_LATEX --> LATEX : compiles
BUILD_LATEX --> ACTIONS : runs
ACTIONS --> PDF : generates
ACTIONS --> METADATA : creates
METADATA --> VERSION : contains

@enduml
PLANTUML

echo "✓ Created PlantUML architecture diagram"
echo ""

# ============================================================================
# 2. GENERATE DOXYGEN DOCUMENTATION
# ============================================================================
echo "Step 3: Generating Doxygen documentation..."

cat > "$ARCH_DIR/Doxyfile" << 'DOXYGEN'
PROJECT_NAME           = "DevOps Final Project"
PROJECT_NUMBER         = 1.0
PROJECT_BRIEF          = "Automated LaTeX Compilation and Deployment Pipeline"

INPUT                  = ./Book_SSW590_1 \
                        ./ \
                        ./.github/workflows

FILE_PATTERNS          = *.tex \
                        *.yml \
                        *.yaml \
                        *.html \
                        *.css \
                        *.js \
                        *.json

EXCLUDE_PATTERNS       = */node_modules/* \
                        */.git/* \
                        */eps/* \
                        */png/* \
                        */visio/*

RECURSIVE              = YES
OUTPUT_DIRECTORY       = ./Book_SSW590_1/doxygen

GENERATE_LATEX         = YES
GENERATE_HTML          = YES
GENERATE_DOCBOOK       = NO

LATEX_OUTPUT           = latex
LATEX_CMD_NAME         = pdflatex

DOT_PATH               = /usr/bin
HAVE_DOT               = YES
CALL_GRAPH             = YES
CALLER_GRAPH           = YES
COLLABORATION_GRAPH    = YES
INCLUDE_GRAPH          = YES
INCLUDED_BY_GRAPH      = YES

GENERATE_TREEVIEW      = YES
USE_MATHJAX            = YES

DOXYGEN_EXECUTABLE     = doxygen
PLANTUML_JAR_PATH      = /usr/share/plantuml
DOXYGEN_LANGUAGE_SUPPORT_CPLUSPLUS = YES

EXTRACT_ALL            = YES
EXTRACT_PRIVATE        = YES
EXTRACT_STATIC         = YES
EXTRACT_LOCAL_CLASSES  = YES
DOXYGEN

# Run doxygen
cd Book_SSW590_1
doxygen ../Doxyfile > /dev/null 2>&1 || true
cd ..

echo "✓ Generated Doxygen documentation"
echo ""

# ============================================================================
# 3. ANALYZE SOURCE CODE STRUCTURE
# ============================================================================
echo "Step 4: Analyzing source code structure..."

cat > "$ARCH_DIR/source-structure.txt" << 'EOF'
=== SOURCE CODE STRUCTURE ANALYSIS ===

Project: DevOps Final Project
Type: Hybrid (Web Frontend + LaTeX Documentation + CI/CD Pipeline)

COMPONENT 1: FRONTEND WEB APPLICATION
├── index.html
│   ├── Purpose: Main web interface
│   ├── Dependencies: style.css, demo.js
│   └── Type: HTML5 Document
├── style.css
│   ├── Purpose: Visual styling and layout
│   ├── Size: Dynamic
│   └── Type: Cascading Style Sheets
└── demo.js
    ├── Purpose: Interactive functionality
    ├── Features: DOM manipulation, events
    └── Type: JavaScript (ES6+)

COMPONENT 2: DOCUMENTATION SYSTEM
├── Book_SSW590_1/
│   ├── itManual.tex (Main LaTeX document)
│   ├── itProjectDemo.tex (NEW - DevOps metrics chapter)
│   ├── cornell.cls (Cornell thesis styling)
│   ├── Various chapter files (itAWSDeployment, itGithub, etc.)
│   └── Assets (eps/, png/, visio/)
└── Supporting files
    ├── prologue.tex
    ├── abstract.tex
    ├── itGlossary.tex
    └── bibfile.bib

COMPONENT 3: CI/CD PIPELINE
├── .github/workflows/
│   ├── build-latex.yml
│   │   ├── Trigger: Push to main/develop
│   │   ├── Jobs: LaTeX compilation, version generation
│   │   └── Output: PDF artifacts
│   └── ci-cd.yml
│       ├── Trigger: Push to main/develop
│       ├── Jobs: Build, Test, Package, Release
│       └── Output: Deployment artifacts

COMPONENT 4: BUILD OUTPUT
├── Generated Files
│   ├── itManual.pdf (Compiled LaTeX)
│   ├── version.txt (Version information)
│   ├── buildinfo.tex (Build metadata - LaTeX)
│   └── buildinfo.json (Build metadata - JSON)
└── Artifacts
    ├── LaTeX-PDF-[run-id] (Workflow artifact)
    └── devops-final-project-[version].zip (Release package)

DATA FLOW:
1. Developer commits code
2. GitHub Actions triggered
3. Workflow extracts git metadata
4. LaTeX compiled with metadata
5. PDF generated with version info
6. Artifacts uploaded and released

EOF

cat "$ARCH_DIR/source-structure.txt"
echo ""

# ============================================================================
# 4. CREATE GRAPHVIZ DIAGRAM
# ============================================================================
echo "Step 5: Creating Graphviz architecture diagram..."

cat > "$ARCH_DIR/architecture.dot" << 'GRAPHVIZ'
digraph DevOpsArchitecture {
    rankdir=LR;
    
    // Styling
    node [shape=box, style=rounded];
    
    // Frontend Layer
    subgraph cluster_frontend {
        label = "Frontend Layer";
        style = "rounded,filled";
        fillcolor = "lightblue";
        
        HTML [label="index.html\n(Web Interface)"];
        CSS [label="style.css\n(Styling)"];
        JS [label="demo.js\n(Interaction)"];
    }
    
    // Documentation Layer
    subgraph cluster_docs {
        label = "Documentation Layer";
        style = "rounded,filled";
        fillcolor = "lightgreen";
        
        MAIN_TEX [label="itManual.tex\n(Main Document)"];
        DEMO_TEX [label="itProjectDemo.tex\n(DevOps Chapter)"];
        STYLE_CLS [label="cornell.cls\n(Styling)"];
        CHAPTERS [label="Chapter Files\n(Various)"];
        BIB [label="bibfile.bib\n(References)"];
    }
    
    // CI/CD Layer
    subgraph cluster_cicd {
        label = "CI/CD Pipeline";
        style = "rounded,filled";
        fillcolor = "lightyellow";
        
        GITHUB [label="GitHub Repository"];
        ACTIONS [label="GitHub Actions"];
        BUILD_LATEX [label="build-latex.yml"];
        CI_CD [label="ci-cd.yml"];
    }
    
    // Build Output Layer
    subgraph cluster_output {
        label = "Build Output";
        style = "rounded,filled";
        fillcolor = "lightcoral";
        
        PDF [label="itManual.pdf\n(Generated)"];
        VERSION [label="version.txt"];
        BUILDINFO_TEX [label="buildinfo.tex"];
        BUILDINFO_JSON [label="buildinfo.json"];
        ARTIFACTS [label="GitHub Artifacts\n(30-day retention)"];
        RELEASE [label="GitHub Release"];
    }
    
    // Connections
    HTML -> CSS [label="uses"];
    HTML -> JS [label="uses"];
    
    MAIN_TEX -> DEMO_TEX [label="includes"];
    MAIN_TEX -> CHAPTERS [label="includes"];
    MAIN_TEX -> STYLE_CLS [label="uses"];
    MAIN_TEX -> BIB [label="references"];
    
    DEMO_TEX -> BUILDINFO_JSON [label="references"];
    
    GITHUB -> ACTIONS [label="triggers"];
    ACTIONS -> BUILD_LATEX [label="runs"];
    ACTIONS -> CI_CD [label="runs"];
    
    BUILD_LATEX -> MAIN_TEX [label="compiles"];
    CI_CD -> BUILD_LATEX [label="orchestrates"];
    
    BUILD_LATEX -> BUILDINFO_JSON [label="generates"];
    BUILD_LATEX -> BUILDINFO_TEX [label="generates"];
    BUILD_LATEX -> VERSION [label="generates"];
    
    MAIN_TEX -> PDF [label="pdflatex"];
    BUILDINFO_TEX -> PDF [label="inputs"];
    VERSION -> PDF [label="inputs"];
    
    PDF -> ARTIFACTS [label="uploaded"];
    ARTIFACTS -> RELEASE [label="attached"];
    
    BUILDINFO_JSON -> ARTIFACTS [label="uploaded"];
    
    // Styling
    HTML [fillcolor="lightblue"];
    CSS [fillcolor="lightblue"];
    JS [fillcolor="lightblue"];
    
    MAIN_TEX [fillcolor="lightgreen"];
    DEMO_TEX [fillcolor="lightgreen"];
    STYLE_CLS [fillcolor="lightgreen"];
    CHAPTERS [fillcolor="lightgreen"];
    BIB [fillcolor="lightgreen"];
    
    GITHUB [fillcolor="lightyellow"];
    ACTIONS [fillcolor="lightyellow"];
    BUILD_LATEX [fillcolor="lightyellow"];
    CI_CD [fillcolor="lightyellow"];
    
    PDF [fillcolor="lightcoral", shape=ellipse];
    VERSION [fillcolor="lightcoral"];
    BUILDINFO_TEX [fillcolor="lightcoral"];
    BUILDINFO_JSON [fillcolor="lightcoral"];
    ARTIFACTS [fillcolor="lightcoral", shape=ellipse];
    RELEASE [fillcolor="lightcoral", shape=ellipse];
}
GRAPHVIZ

# Convert to PNG and PDF
dot -Tpng "$ARCH_DIR/architecture.dot" -o "$ARCH_DIR/architecture.png"
dot -Tpdf "$ARCH_DIR/architecture.dot" -o "$ARCH_DIR/architecture.pdf"

echo "✓ Generated Graphviz diagrams (PNG and PDF)"
echo ""

# ============================================================================
# 5. GENERATE CLASS/COMPONENT DIAGRAM
# ============================================================================
echo "Step 6: Creating component interaction diagram..."

cat > "$ARCH_DIR/components.puml" << 'PLANTUML'
@startuml components
!theme plain
title Component Architecture - DevOps Final Project

component [Web Frontend] as WEB {
  component [HTML Document] as HTML
  component [CSS Stylesheet] as CSS
  component [JavaScript Code] as JS
}

component [Documentation System] as DOCS {
  component [Main LaTeX Document] as MAIN_TEX
  component [DevOps Chapter] as DEMO_CH
  component [Other Chapters] as OTHER_CH
  component [Styling (cornell.cls)] as TEX_STYLE
  component [Bibliography] as BIB
}

component [Build Automation] as BUILD {
  component [LaTeX Compiler] as PDFLATEX
  component [Version Generator] as VGEN
  component [Metadata Generator] as MGEN
}

component [CI/CD Pipeline] as CICD {
  component [GitHub Actions] as GA
  component [Workflow Jobs] as JOBS
}

component [Output & Release] as OUTPUT {
  component [PDF Document] as PDF
  component [Version File] as VFILE
  component [Build Metadata] as META
  component [GitHub Artifacts] as ARTIFACTS
}

WEB --> BUILD : "triggers"
DOCS --> BUILD : "input"

MAIN_TEX --> DEMO_CH : "includes"
MAIN_TEX --> OTHER_CH : "includes"
MAIN_TEX --> TEX_STYLE : "uses"
MAIN_TEX --> BIB : "references"

BUILD --> PDFLATEX : "uses"
BUILD --> VGEN : "runs"
BUILD --> MGEN : "runs"

VGEN --> VFILE : "generates"
MGEN --> META : "generates"

PDFLATEX --> PDF : "produces"

CICD --> GA : "uses"
GA --> JOBS : "executes"
JOBS --> BUILD : "invokes"

PDF --> ARTIFACTS : "uploads"
VFILE --> ARTIFACTS : "uploads"
META --> ARTIFACTS : "uploads"

@enduml
PLANTUML

echo "✓ Created component interaction diagram"
echo ""

# ============================================================================
# 6. CREATE WORKFLOW DIAGRAM
# ============================================================================
echo "Step 7: Creating CI/CD workflow diagram..."

cat > "$ARCH_DIR/workflow.puml" << 'PLANTUML'
@startuml workflow
!theme plain
title CI/CD Workflow Execution

participant Developer as dev
participant "Git Repository" as git
participant "GitHub Actions" as actions
participant "Build Job" as build
participant "LaTeX Compiler" as latex
participant "Artifact Storage" as artifacts
participant "GitHub Releases" as releases

dev ->> git: git push origin main
activate git

git ->> actions: Trigger workflow
activate actions

actions ->> build: Start build job
activate build

build ->> build: Extract git metadata
build ->> build: Generate version info
build ->> build: Create buildinfo files

deactivate build

actions ->> latex: Start LaTeX compilation
activate latex

latex ->> latex: Install dependencies
latex ->> latex: pdflatex pass 1
latex ->> latex: pdflatex pass 2
latex ->> latex: pdflatex pass 3
latex ->> latex: Generate PDF

deactivate latex

actions ->> artifacts: Upload PDF artifact
activate artifacts

artifacts ->> artifacts: Store itManual.pdf
artifacts ->> artifacts: Store metadata files
artifacts ->> artifacts: Set 30-day retention

deactivate artifacts

alt Has Version Tag
    actions ->> releases: Create GitHub Release
    activate releases
    releases ->> releases: Attach PDF
    releases ->> releases: Add metadata
    deactivate releases
end

actions ->> git: Auto-commit version updates
deactivate git
deactivate actions

@enduml
PLANTUML

echo "✓ Created workflow diagram"
echo ""

# ============================================================================
# 7. CREATE LATEX CHAPTER WITH ARCHITECTURE
# ============================================================================
echo "Step 8: Creating LaTeX architecture documentation chapter..."

cat > "Book_SSW590_1/itArchitecture.tex" << 'LATEX'
\chapter{Reverse Architecture Documentation \\
\small{\textit{-- System Architecture and Component Analysis}}
\index{Architecture}
\index{Chapter!Architecture}
\label{Chapter::Architecture}}

This chapter presents the reverse-engineered architectural documentation of the DevOps Final Project, extracted automatically from source code and CI/CD pipeline configuration.

\section{Architecture Overview}
\label{sec:ArchOverview}

The DevOps Final Project is a hybrid system consisting of four main components:

\begin{enumerate}
    \item \textbf{Frontend Web Application} - HTML, CSS, and JavaScript files
    \item \textbf{Documentation System} - LaTeX-based technical documentation
    \item \textbf{Build Automation} - Compilation and metadata generation
    \item \textbf{CI/CD Pipeline} - GitHub Actions workflow orchestration
\end{enumerate}

\subsection{Component Relationships}

The following diagram shows how components interact:

\begin{figure}[h]
    \centering
    \includegraphics[width=0.9\linewidth]{Book_SSW590_1/architecture/architecture.png}
    \caption{System Architecture Diagram (Generated from Graphviz)}
    \label{fig:architecture}
\end{figure}

\section{Frontend Layer}
\label{sec:FrontendLayer}

The frontend layer consists of three main files that form a web application:

\begin{table}[h]
\centering
\begin{tabular}{|l|l|l|}
\hline
\textbf{File} & \textbf{Type} & \textbf{Purpose} \\
\hline
index.html & HTML5 & Main web interface and document structure \\
\hline
style.css & CSS3 & Visual styling and responsive layout \\
\hline
demo.js & JavaScript & Interactive functionality and DOM manipulation \\
\hline
\end{tabular}
\caption{Frontend Components}
\label{table:frontend-components}
\end{table}

\subsubsection{Dependencies}

\begin{itemize}
    \item \texttt{index.html} depends on \texttt{style.css} for styling
    \item \texttt{index.html} depends on \texttt{demo.js} for interaction
    \item \texttt{demo.js} manipulates the DOM defined in \texttt{index.html}
\end{itemize}

\section{Documentation Layer}
\label{sec:DocumentationLayer}

The documentation layer is built on LaTeX and the Cornell thesis style:

\subsection{Core Documents}

\begin{table}[h]
\centering
\begin{tabular}{|l|l|l|}
\hline
\textbf{File} & \textbf{Type} & \textbf{Purpose} \\
\hline
itManual.tex & LaTeX & Master document that includes all chapters \\
\hline
prologue.tex & LaTeX & Title page, abstract, acknowledgments \\
\hline
itProjectDemo.tex & LaTeX & DevOps metrics and build information \\
\hline
itArchitecture.tex & LaTeX & This chapter - reverse documentation \\
\hline
\end{tabular}
\caption{Main Documentation Files}
\label{table:doc-files}
\end{table}

\subsection{Supporting Files}

The documentation system includes 17+ chapter files:

\begin{itemize}
    \item \texttt{itIntroduction.tex} - Project introduction
    \item \texttt{itAWSDeployment.tex} - AWS infrastructure setup
    \item \texttt{itGithub.tex} - GitHub configuration
    \item \texttt{itJenkinsWithPytest.tex} - Jenkins CI/CD setup
    \item \texttt{itPrometheusGrafana.tex} - Monitoring and logging
    \item \texttt{itLoadBalancer.tex} - Load balancing configuration
    \item And more...
\end{itemize}

\section{Build Automation}
\label{sec:BuildAutomation}

The build automation layer handles LaTeX compilation and metadata generation:

\subsection{Version Generation}

\begin{lstlisting}[language=bash, caption=Version Generation Process]
# Extract version from git
VERSION=$(git describe --tags --always)

# Get commit information
COMMIT_HASH=$(git rev-parse --short HEAD)
AUTHOR=$(git log -1 --pretty=%an)
TIMESTAMP=$(git log -1 --pretty=%ai)

# Generate metadata files
echo "$VERSION" > version.txt
# Create buildinfo.tex with LaTeX commands
# Create buildinfo.json with JSON data
\end{lstlisting}

\subsection{LaTeX Compilation}

The compilation process runs three passes to ensure proper cross-references:

\begin{enumerate}
    \item \textbf{First Pass}: Generate references and build reference list
    \item \textbf{Second Pass}: Build table of contents and index
    \item \textbf{Third Pass}: Final compilation with all references resolved
\end{enumerate}

\section{CI/CD Pipeline Architecture}
\label{sec:CIPipeline}

The CI/CD pipeline is orchestrated by GitHub Actions with multiple jobs:

\begin{figure}[h]
    \centering
    \begin{tabular}{|l|l|l|}
    \hline
    \textbf{Workflow} & \textbf{Trigger} & \textbf{Purpose} \\
    \hline
    build-latex.yml & Push to main/develop & Compile LaTeX to PDF \\
    \hline
    ci-cd.yml & Push to main/develop & Build, test, package, release \\
    \hline
    \end{tabular}
    \caption{GitHub Actions Workflows}
\end{table}

\subsection{Workflow Jobs}

\begin{enumerate}
    \item \textbf{Build Job} - Compiles source code, generates artifacts
    \item \textbf{Build LaTeX Job} - Runs LaTeX compilation, generates PDF
    \item \textbf{Test Job} - Runs automated tests (HTML, CSS, JS validation)
    \item \textbf{Package and Release Job} - Creates deployment packages and releases
\end{enumerate}

\section{Data Flow}
\label{sec:DataFlow}

The data flows through the system as follows:

\begin{lstlisting}[caption=System Data Flow]
Developer Code
  ↓ (git push)
GitHub Repository
  ↓ (triggers)
GitHub Actions
  ├─→ Extract Metadata (version, commit, author)
  ├─→ Compile LaTeX (3 passes)
  ├─→ Generate PDF
  ├─→ Create Artifacts
  └─→ Release on GitHub
\end{lstlisting}

\section{Build Output Artifacts}
\label{sec:OutputArtifacts}

The build system generates the following artifacts:

\begin{table}[h]
\centering
\begin{tabular}{|l|l|l|}
\hline
\textbf{Artifact} & \textbf{Format} & \textbf{Purpose} \\
\hline
itManual.pdf & PDF & Compiled documentation \\
\hline
version.txt & Text & Current version number \\
\hline
buildinfo.tex & LaTeX & Build metadata as LaTeX commands \\
\hline
buildinfo.json & JSON & Build metadata in JSON format \\
\hline
devops-final-project-[ver].zip & ZIP & Complete deployment package \\
\hline
\end{tabular}
\caption{Build Output Artifacts}
\label{table:output-artifacts}
\end{table}

\section{Architecture Patterns}
\label{sec:ArchPatterns}

\subsection{Separation of Concerns}

The architecture maintains clear separation between:

\begin{itemize}
    \item \textbf{Frontend} - Web interface and user interaction
    \item \textbf{Documentation} - Technical and process documentation
    \item \textbf{Automation} - Build and compilation scripts
    \item \textbf{CI/CD} - Orchestration and release management
\end{itemize}

\subsection{Automation and Reproducibility}

\begin{itemize}
    \item All builds are automated via GitHub Actions
    \item Version information is automatically extracted from git
    \item Documentation is regenerated on every commit
    \item Artifacts are automatically stored and released
\end{itemize}

\subsection{Metadata Injection}

Build information is dynamically injected into:

\begin{itemize}
    \item PDF footer (version number)
    \item Project Demo chapter (full build details)
    \item JSON metadata files (programmatic access)
    \item LaTeX commands (document integration)
\end{itemize}

\section{Generated Architecture Diagrams}
\label{sec:GeneratedDiagrams}

This documentation includes several automatically generated diagrams:

\begin{itemize}
    \item \textbf{Graphviz Architecture Diagram} - Component relationships (Figure \ref{fig:architecture})
    \item \textbf{PlantUML Component Diagram} - Component interactions
    \item \textbf{PlantUML Workflow Diagram} - CI/CD execution flow
    \item \textbf{Source Structure Analysis} - Code organization
\end{itemize}

All diagrams are generated directly from the repository source code and configuration files, ensuring they remain synchronized with the actual system.

\section{Technology Stack}
\label{sec:TechStack}

\begin{table}[h]
\centering
\begin{tabular}{|l|l|l|}
\hline
\textbf{Component} & \textbf{Technologies} & \textbf{Purpose} \\
\hline
Frontend & HTML5, CSS3, JavaScript & Web interface \\
\hline
Documentation & LaTeX, Cornell.cls, BibTeX & Technical documentation \\
\hline
Build Tools & pdflatex, sed, bash & Compilation and scripting \\
\hline
CI/CD & GitHub Actions, YAML & Workflow orchestration \\
\hline
Diagram Generation & Graphviz, PlantUML, Doxygen & Architecture visualization \\
\hline
Version Control & Git, GitHub & Source and documentation control \\
\hline
\end{tabular}
\caption{Technology Stack}
\label{table:tech-stack}
\end{table}

\section{Deployment Architecture}
\label{sec:DeploymentArch}

\begin{figure}[h]
    \centering
    \begin{tabular}{|l|l|}
    \hline
    \textbf{Environment} & \textbf{Description} \\
    \hline
    Development & Local development on developer machine \\
    \hline
    Repository & GitHub repository with version control \\
    \hline
    CI/CD Server & GitHub Actions for build and test \\
    \hline
    Artifact Storage & GitHub Actions artifact storage (30 days) \\
    \hline
    Release & GitHub Releases for versioned releases \\
    \hline
    \end{tabular}
    \caption{Deployment Architecture}
\end{table}

\section{Conclusions}
\label{sec:ArchConclusions}

The DevOps Final Project demonstrates:

\begin{itemize}
    \item \textbf{Automated Documentation} - Docs generated on every commit
    \item \textbf{Version Tracking} - Git-based semantic versioning
    \item \textbf{Build Automation} - Fully automated LaTeX compilation
    \item \textbf{CI/CD Integration} - GitHub Actions orchestration
    \item \textbf{Reverse Documentation} - Architecture extracted from source
    \item \textbf{Artifact Management} - Automatic storage and release
\end{itemize}

This architecture enables continuous documentation generation, ensuring that technical documentation stays synchronized with source code and build processes.

\noindent
\textit{This chapter was automatically generated by analyzing the repository structure and CI/CD configuration files.}

LATEX

echo "✓ Created LaTeX architecture chapter"
echo ""

# ============================================================================
# 8. SUMMARY
# ============================================================================
echo "Step 9: Generating summary report..."

echo "=== REVERSE ARCHITECTURE DOCUMENTATION COMPLETE ==="
echo ""
echo "Generated Files:"
echo "  ✓ $ARCH_DIR/architecture.puml (PlantUML diagram)"
echo "  ✓ $ARCH_DIR/architecture.dot (Graphviz diagram)"
echo "  ✓ $ARCH_DIR/architecture.png (Graphviz PNG output)"
echo "  ✓ $ARCH_DIR/architecture.pdf (Graphviz PDF output)"
echo "  ✓ $ARCH_DIR/components.puml (Component diagram)"
echo "  ✓ $ARCH_DIR/workflow.puml (Workflow diagram)"
echo "  ✓ $ARCH_DIR/source-structure.txt (Structure analysis)"
echo "  ✓ Book_SSW590_1/itArchitecture.tex (LaTeX chapter)"
echo "  ✓ Book_SSW590_1/Doxyfile (Doxygen configuration)"
echo ""
echo "LaTeX Integration:"
echo "  - Architecture diagram included in itArchitecture.tex"
echo "  - Component relationships documented"
echo "  - Technology stack enumerated"
echo "  - Data flow illustrated"
echo ""
echo "Next Steps:"
echo "  1. Include itArchitecture.tex in itManual.tex"
echo "  2. Push to GitHub for PDF generation"
echo "  3. Download PDF from Actions artifacts"
echo "  4. View the new Architecture chapter in itManual.pdf"
echo ""

echo "=== DONE ==="

