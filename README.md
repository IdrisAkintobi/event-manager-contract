# EventNFT Smart Contract Project

## Overview

This project contains a suite of smart contracts for creating and managing Event NFTs (ERC721), which represent tickets for events. The contracts are written in Solidity and are designed to be deployed on the Ethereum blockchain. It allows event organizers to mint NFTs for their events, manage attendance, and control access based on event status.

## Contracts

### 1. **EventNFT Contract**

The `EventNFT` contract is an ERC721-compliant NFT contract, using `ERC721URIStorage` from OpenZeppelin to manage NFTs for events. The contract allows event organizers to mint tickets (as NFTs), manage the maximum number of attendees, and update event statuses.

Key Features:

- **Minting Tickets**: Only the event owner can mint tickets (as NFTs) up to the defined maximum attendance.
- **Toggling Event Status**: The event can be opened or closed by the owner.
- **Transferring Tickets**: Users can transfer their event tickets to another person.
- **Burning Tickets**: A ticket is automatically burned when used, preventing reuse.
- **Custom Errors**: Includes meaningful error messages for edge cases like max attendance reached, event closed, or invalid owner.

Events:

- `toggledEventIsOpen`: Triggered when the event's open status is toggled.
- `grantEventAccess`: Emitted when a user successfully uses their ticket to gain access to the event.
- `ticketTransfered`: Triggered when a ticket is transferred between users.

### 2. **EventManager Contract**

The `EventManager` contract acts as a factory to deploy `EventNFT` contracts. Event organizers can create new events by paying a creation fee in an ERC20 token specified at contract deployment.

Key Features:

- **Create Event**: Deploys a new `EventNFT` contract with specified parameters like event owner, name, symbol, and maximum attendance.
- **Charge Event Creation Fee**: The organizer must pay a fee in an ERC20 token to create a new event.
- **Event Tracking**: Maintains a record of all deployed `EventNFT` contracts for future reference.

Events:

- `EventNFTCreated`: Emitted when a new event is successfully created.

### 3. **EventNFTModifier Contract**

This is an abstract contract used as a base for `EventNFT`. It defines common functionality related to event ownership and ticket validation.

Key Features:

- **Owner Authorization**: Restricts critical operations to the event owner.
- **Ticket Holder Validation**: Ensures that only the rightful holder of a ticket can use it.
- **Event Validity**: Ensures that the event has not yet ended before certain operations can be performed.

Custom Errors:

- `EventNFTModifierUnauthorizedAccount`: Thrown when an unauthorized account attempts to perform a restricted action.
- `EventHasEnded`: Thrown if the event has already ended and the operation is invalid.

## How It Works

### Deployment Flow:

1. **Create an Event**: The event organizer calls the `createEventNFT` function on the `EventManager` contract, which deploys a new `EventNFT` contract.
2. **Minting Tickets**: The event organizer mints NFTs (tickets) by calling `mintTicket` on their `EventNFT` contract.
3. **Managing Event**: The organizer can toggle the event's status (open/closed) and update the event's end date if needed.
4. **Using Tickets**: Attendees can use their tickets to gain access to the event. When a ticket is used, it is burned to prevent reuse.
5. **Transferring Tickets**: Users can transfer their tickets to other users before the event starts.

## Installation

NB: Ensure you have [Foundry](https://book.getfoundry.sh/) installed.

To use these contracts, clone the repository and install the required dependencies:

```bash
git clone <repository-url>
cd <project-directory>
forge install
```

### Compilation

The contracts are written in Solidity and can be compiled using the following command:

```bash
forge build
```

### Deployment

NB: Add the network of your choice to the foundry.toml file and add your deployment to the makefile.

Deploying the contracts on lisk-sepolia:

Deploy the token

```bash
make IDrisToken
```

### Deploy the events manager contract

NB: Update the environment variable `EVENT_MANAGER_TOKEN` with the deployed token address.

```bash
make EventManager
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
