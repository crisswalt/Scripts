# Scripts

A GitHub-executable script system that enables automated installations and configurations with simple, interactive workflows.

## What is Scripts?

Scripts is a project that provides robust infrastructure for creating and executing automation scripts directly from GitHub. It includes a Vite-style interactive system, multi-language support, and shared utilities that make it easy to create consistent user experiences.

## Features

- **Direct execution**: Executable scripts with a simple `curl` command
- **Interactive system**: Vite-style interface for collecting configurations
- **Multi-language**: Full internationalization support
- **Modular**: Reusable utility system
- **Validations**: Robust input validation system
- **Logging**: Uniform and colorized logging functions

## Quick Start

Execute any script directly from GitHub:

```bash
bash -c "$(curl 'https://raw.githubusercontent.com/crisswalt/Scripts/main/drupal/11/install.sh')"
```

## Available Scripts

### Drupal
- `drupal/11/install.sh` - Interactive Drupal 11 installation

### Tools
- `tools/nodejs/install.sh` - Node.js installation
- More scripts in development...

## For Developers

### Option 1: Personal Fork (Recommended)

For specific or custom scripts, we recommend forking:

1. **Fork this repository**
2. **Create your scripts** following conventions
3. **Execute from your fork**:
   ```bash
   bash -c "$(curl 'https://raw.githubusercontent.com/your-username/Scripts/main/your-script.sh')"
   ```

**Fork advantages:**
- Full control over your scripts
- Independent versioning
- Unrestricted customization
- Private script possibilities

### Option 2: Contribute to Main Project

We accept contributions for **common solutions** that benefit the community:

**Contribution criteria:**
- Scripts solving frequent problems
- Popular software installations
- Standard development configurations
- General-purpose utilities

**We don't accept:**
- Very specific company/project scripts
- Personal configurations
- Experimental or beta scripts
- Niche solutions with limited use

## Creating a Script

### Basic Structure

```bash
#!/bin/bash

# category/version/script.sh
# Script description
# Usage: bash -c "$(curl 'https://raw.githubusercontent.com/crisswalt/Scripts/main/category/version/script.sh')"

set -e

# Load environment variables
[ -f ".env" ] && source .env

# Import bootstrap
BASEURL=${BASEURL:-"https://raw.githubusercontent.com/crisswalt/Scripts/main"}
if ! source <(curl -fsSL "${BASEURL}/bootstrap.sh"); then
    log_error "Failed to import bootstrap"
    exit 1
fi

# Import utilities
import "utilities/translator.sh"
import "utilities/interactive.sh"

# Configuration
SCRIPT_SPECIFIC_PO_PATH="translations/my-script"

# Your logic here...
```

### Interactive System

```bash
setup_interactive_config() {
    setup_clear
    setup_title "$(trans "🚀 My Script")"
    
    # Request input
    setup_input "project_name" \
                "$(trans "Project name")" \
                "my-project" \
                "validate_project_name"
    
    # Multiple selection
    local options=("Option 1" "Option 2" "Option 3")
    setup_select "option" \
                 "$(trans "Select an option")" \
                 options \
                 0
    
    # Confirmation
    setup_confirm "proceed" \
                  "$(trans "Continue with installation?")" \
                  "y"
    
    # Show summary
    setup_summary
    
    if [[ "$(setup_get "proceed")" == "yes" ]]; then
        run_installation
    else
        log_info "Installation cancelled"
        exit 0
    fi
}
```

### Logging Functions

```bash
log_info "General information"
log_success "Successful operation"
log_warning "Important warning"
log_error "Critical error"
```

## Available Functions

### Bootstrap
- `require "url"` - Downloads content from a URL
- `import "script"` - Imports project utilities

### Interactive System
- `setup_clear` - Clears the screen
- `setup_title` - Sets main title
- `setup_input` - Requests text input
- `setup_select` - Presents selection options
- `setup_confirm` - Requests yes/no confirmation
- `setup_get` - Gets configured value
- `setup_summary` - Shows configuration summary

### Logging
- `log_info` - Informational message
- `log_success` - Success message
- `log_warning` - Warning message
- `log_error` - Error message

## Project Structure

```
Scripts/
├── README.md
├── bootstrap.sh              # Base functions
├── utilities/               # Shared utilities
│   ├── translator.sh        # Translation system
│   └── interactive.sh       # Interactive system
├── translations/            # Translation files
├── drupal/                  # Drupal scripts
│   └── 11/
│       └── install.sh
└── tools/                   # General tools
    └── nodejs/
        └── install.sh
```

## Environment Variables

- `BASEURL` - Repository base URL (default: official repository)
- `DEBUG` - Enables debug mode (`true`/`false`)
- `DRY_RUN` - Test mode without executing changes (`true`/`false`)

## Contributing

### Before Contributing

Consider if your script is **general use** or **specific**:

- **General use**: Popular software installations, standard configurations
- **Specific**: Personal configurations, company scripts

For specific scripts, use a personal fork.

### Contribution Process

1. Fork the project
2. Create a branch: `git checkout -b feature/my-script`
3. Develop following conventions
4. Test your script thoroughly
5. Commit: `git commit -m "feat: add X installation script"`
6. Push: `git push origin feature/my-script`
7. Create a Pull Request

### Conventions

- Use predefined logging functions
- Implement interactive system
- Include robust validations
- Document environment variables
- Follow directory structure
- Include basic translations

## Documentation

- [Script Creation Guide](lista-de-funciones-del-proyecto.md) - Complete developer documentation
- [Code Conventions](CONTRIBUTING.md) - Project standards

## Examples

### Simple Installation
```bash
# Install Drupal 11
bash -c "$(curl 'https://raw.githubusercontent.com/crisswalt/Scripts/main/drupal/11/install.sh')"
```

### With Environment Variables
```bash
# Install with custom configuration
PROJECT_NAME="my-site" ENVIRONMENT="production" \
bash -c "$(curl 'https://raw.githubusercontent.com/crisswalt/Scripts/main/drupal/11/install.sh')"
```

### From Personal Fork
```bash
# Execute from your fork
bash -c "$(curl 'https://raw.githubusercontent.com/your-username/Scripts/main/my-script.sh')"
```

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

- **Issues**: Report bugs or request features
- **Discussions**: Questions and general discussions
- **Wiki**: Additional documentation and examples

---

**Have a useful script?** 
- If it's specific → Create a fork
- If it's general use → Contribute to the project