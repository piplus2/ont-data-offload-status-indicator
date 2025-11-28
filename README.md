# Oxford Nanopore Data Offload Status Indicator

Oxford Nanopore has recently introduced a new service called `ont-platform-data-offload` to manage data offloading from their sequencing devices.
This project provides a convenient way to monitor the status of this service directly from your GNOME desktop environment.

The main component is an [Argos](https://github.com/p-e-w/argos) script to monitor the `ont-platform-data-offload` service directly from the GNOME top bar. It provides real-time status updates on data offloading processes, specifically tracking active `rsync` transfers.

## Features

- **Status Icons**: Visual indicators for service state:
  - ⚪ Idle (No active transfers)
  - 🟢 Syncing (Active transfers in progress)
  - 🔴 Error (Service is down or ghosted)
- **Active Transfer Monitoring**: Lists the filenames of files currently being transferred via `rsync`.
- **Quick Actions**:
  - Start/Restart the `ont-platform-data-offload` service.
  - View service logs in a terminal.
  - Open the main log file.
- **Log Preview**: Shows the last log entry in the dropdown menu.

## Requirements

- **OS**: Linux (GNOME Desktop Environment)
- **Extension**: [Argos](https://github.com/p-e-w/argos) GNOME Shell Extension.
- **Dependencies**:
  - `bash`
  - `systemd` (for `systemctl`)
  - `rsync`
  - `gnome-terminal`
  - `pgrep`

## Installation

1.  **Install Argos**: Follow the instructions on the [Argos GitHub page](https://github.com/p-e-w/argos) to install the extension.

2.  **Download the Script**:
    Clone this repository or download `argos-monitor.1m.sh`.

3.  **Deploy**:
    Copy the script to the Argos configuration directory.

    ```bash
    mkdir -p ~/.config/argos
    cp argos-monitor.1m.sh ~/.config/argos/
    ```

4.  **Make Executable**:
    ```bash
    chmod +x ~/.config/argos/argos-monitor.1m.sh
    ```

The indicator should appear in your top bar immediately (or within 1 minute).

## Configuration

You can customize the script by editing the variables at the top of `argos-monitor.1m.sh`:

- `SERVICE_NAME`: The name of the systemd service to monitor (default: `ont-platform-data-offload`).
- `LOG_FILE`: Path to the log file for quick access (default: `/data/data-offload.log`).

## Refresh Time

The script refreshes every minute by default. You can change the refresh interval by renaming the script file to `argos-monitor.Xm.sh`, where `X` is the number of minutes between refreshes.

## Troubleshooting

- **Service Down**: If the icon is red, click it and select "Start Service" or "View Logs" to investigate.
- **Ghost Service**: If the service is active but the main PID is missing, the script will report a "Ghost" status. Use the "Restart" option.

## License

See [LICENSE](LICENSE) file.
