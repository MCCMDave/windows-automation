# Windows Automation

## About

Professional automation tools for Windows system management. This repository contains scripts and tools that streamline software updates and system maintenance across multiple Windows environments.

## Projects

### Universal Update Manager v2.1 ⭐

**Development Approach:** AI-Assisted Development  
**Role:** Project Owner, Requirements Engineer, Quality Assurance

**Purpose:** Centralized update management for Windows systems, combining multiple update sources (Windows Update, Microsoft Store, Chocolatey) into a single automated workflow.

**Key Features:**
- Automated Windows Update management
- Microsoft Store app updates
- Chocolatey package management integration
- Logging and reporting
- Multi-system deployment (tested on 2 production systems)
- Error handling and user feedback

**Technologies:**
- PowerShell 5.1+
- Windows Update API
- Chocolatey package manager
- JSON configuration management
- Batch scripting (launcher)
- Git version control

**Project Structure:**
- `universal-update-manager.ps1` - Main PowerShell script
- `universal-update-manager.bat` - Launcher for administrator privileges
- `update-config.json` - User-configurable settings

**My Responsibilities:**
- **Requirements Engineering:** Defined automation requirements based on real-world system management needs
- **Workflow Design:** Created user-friendly update workflow optimizing for minimal user intervention
- **Quality Assurance:** Comprehensive testing across two different Windows 11 systems (Desktop and Laptop)
- **Documentation:** Created usage documentation and deployment guides
- **Production Deployment:** Successfully deployed to production environment

**Test Environment:**
- MSI Desktop: Intel i7-13700F, NVIDIA RTX 4060, 32GB RAM
- Lenovo Laptop: Intel Core Ultra 5, 32GB RAM
- Both systems running Windows 11 with different configurations

**Why AI-Assisted Development?**

Modern system administration increasingly requires effective use of AI tools to accelerate development and improve code quality. This project demonstrates my ability to:
- Translate business requirements into technical specifications
- Work effectively with AI development tools (a valuable skill in modern DevOps/CSE roles)
- Validate and test complex automation thoroughly
- Deploy and maintain production systems
- Document and support automated solutions

The use of AI assistance allowed me to focus on what matters most in Customer Success Engineering: understanding customer needs, designing effective solutions, and ensuring reliable deployment.

## Development Philosophy

**Collaboration with AI Tools:**

In professional environments, the ability to effectively leverage AI tools is increasingly valuable. This project showcases:
- **Problem Definition:** Clear articulation of requirements and constraints
- **Solution Validation:** Rigorous testing to ensure code meets specifications
- **Production Readiness:** Deployment and maintenance in real-world environments
- **Knowledge Transfer:** Creating documentation for future maintenance

**Key Skills Demonstrated:**
- Requirements gathering and analysis
- System integration (multiple update sources)
- Testing methodology (multi-system validation)
- Production deployment and support
- PowerShell scripting understanding

## Technical Details

**System Requirements:**
- Windows 10/11
- PowerShell 5.1 or higher
- Administrator privileges
- Internet connectivity
- Chocolatey (optional, for package management)

**Integration Points:**
- Windows Update Service
- Microsoft Store
- Chocolatey package repository
- Windows event logging

## Use Cases

**Primary Use Case:**
Centralized update management for home lab environment with multiple Windows systems, reducing manual update overhead and ensuring consistent patching across systems.

**Benefits:**
- Time savings through automation
- Consistent update application across systems
- Comprehensive logging for troubleshooting
- Reduced manual intervention required

## Future Enhancements

**Planned Features:**
- Remote execution capability
- Extended reporting and analytics
- Update scheduling options
- Integration with additional package managers
- Configuration management

## Learning Context

This project is part of my broader infrastructure automation journey, complementing my Cloud IT Administrator certification (IHK). It demonstrates:
- Cross-platform skills (Windows + Linux homelab)
- Automation-first mindset
- Production system management
- Modern development practices with AI tools

## Related Projects

For Linux-based automation and monitoring, see my [homelab-automation](https://github.com/MCCMDave/homelab-automation) repository.

## Important Note

This tool requires administrator privileges and modifies system settings. Always test thoroughly in a non-production environment before deployment. Review code before execution.

## Contact

For questions about implementation or collaboration opportunities, feel free to reach out via GitHub.

---

**Last Updated:** November 2025  
**Version:** 2.1  
**Training Program:** Cloud IT Administrator (IHK) - Module 2 of 4
