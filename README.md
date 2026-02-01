🦁 ThakurOS

    A custom-engineered, reproducible Arch Linux distribution built for stability and standardized development environments.

🚀 Project Overview

ThakurOS is a custom Linux distribution architected from the ground up using the Arch Linux base. Unlike standard installations, this OS is built using a declarative build pipeline (archiso), ensuring that the entire operating system state—from installed packages to system configurations—is defined in code.

This project demonstrates Systems Engineering capabilities, specifically focusing on automated provisioning, kernel configuration for virtualized environments, and reproducible infrastructure.
🛠️ Key Engineering Features

    Declarative Packaging: Utilizes a strict manifest (packages.x86_64) to define the system state, eliminating "drift" and ensuring every build is identical.

    Automated Provisioning: Features a custom engineering script (custom_build.sh) that:

        Automates user creation and permission group assignments (wheel, adm).

        Configures systemd services (NetworkManager, Bluetooth, SDDM) at the root level (airootfs) before boot.

        Injects custom security policies and password hashing using OpenSSL.

    Virtualized Optimization: Includes a curated driver stack (open-vm-tools, spice-vdagent, mesa) specifically tuned for high-performance deployment on hypervisors like Oracle VirtualBox and VMware.

    Custom Desktop Environment: Pre-configured KDE Plasma session with SDDM, offering a balance of performance and modern UI/UX.

📂 Project Structure
Bash

ThakurOS/
├── custom_build.sh      # Main provisioning logic (User setups, systemd links)
├── packages.x86_64      # Declarative list of all system packages
├── profiledef.sh        # ISO build definitions (Name, Architecture, Boot modes)
├── pacman.conf          # Repository configurations
└── airootfs/            # The root file system overlay (Config injection)

💻 How to Build

If you want to compile ThakurOS from source, follow these steps on an Arch Linux machine:
1. Prerequisites

You need the archiso build tools installed:
Bash

sudo pacman -S archiso git

2. Clone the Repository
Bash

git clone https://github.com/HarshThakur47/ThakurOS.git
cd ThakurOS

3. Build the ISO

Execute the build script with root privileges to assemble the file system:
Bash

sudo ./build.sh

The build process will download packages, generate the root filesystem, and compress the final ISO into the out/ directory.
🧪 Testing

The generated ISO (out/ThakurOS-x86_64.iso) is validated to boot on:

    Bare Metal: UEFI and BIOS systems.

    VirtualBox: Requires VMSVGA graphics controller with 3D Acceleration enabled.

    VMware Workstation: Native support via open-vm-tools.

📜 License

This project is open-source and available under the MIT License.

Architected by Harshwardhan Singh Thakur as a Systems Engineering Project.