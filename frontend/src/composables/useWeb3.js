import { ref, readonly } from 'vue';
import Web3Modal from 'web3modal';
import { ethers } from 'ethers';
import axios from 'axios';

// --- Non-reactive, module-level variables for the instances ---
let web3ModalInstance = null;
let provider = null;
let signer = null;
let isConnecting = false; // Add connection state tracking

// --- Reactive state, kept simple and clean ---
const account = ref(null);
const isConnected = ref(false);
const connectionError = ref(null);

// --- Provider Options ---
const providerOptions = {
  /* future wallet integrations */
};

const initWeb3Modal = () => {
    if (!web3ModalInstance) {
        web3ModalInstance = new Web3Modal({
            cacheProvider: true,
            providerOptions,
            theme: 'dark',
        });
    }
};

const subscribeToProviderEvents = (instance) => {
    instance.on("accountsChanged", (accounts) => {
        console.log("Event: accountsChanged", accounts);
        account.value = accounts[0] || null;
        if (!accounts[0]) {
            disconnectWallet();
        }
    });

    instance.on("chainChanged", () => {
        console.log("Event: chainChanged");
        // Reload to reconnect with the new chain info.
        window.location.reload();
    });

    instance.on("disconnect", () => {
        console.log("Event: disconnect");
        disconnectWallet();
    });
};

const loginAndFetchUser = async (userAccount) => {
    if (!userAccount) return null;
    try {
        console.log(`Calling backend login for account: ${userAccount}`);
        const response = await axios.post('http://localhost:3000/api/auth/login', {
            walletAddress: userAccount
        });
        console.log('Backend login response:', response.data);
        return response.data.user;
    } catch (error) {
        console.error('Error calling backend login API:', error);
        return null;
    }
};

const connectWallet = async () => {
    // Prevent multiple simultaneous connection attempts
    if (isConnecting) {
        console.log("Connection already in progress, please wait...");
        return null;
    }

    if (isConnected.value) {
        console.log("Wallet already connected");
        return { account: account.value, isConnected: true };
    }

    isConnecting = true;
    connectionError.value = null;

    try {
        // Clear any existing instance and cached provider to prevent pending requests
        if (web3ModalInstance) {
            web3ModalInstance.clearCachedProvider();
            web3ModalInstance = null;
        }

        // Initialize fresh Web3Modal instance
        initWeb3Modal();

        console.log("Attempting to connect wallet...");
        const instance = await web3ModalInstance.connect();
        
        // Subscribe to provider events
        subscribeToProviderEvents(instance);
        
        // Create provider and signer
        provider = new ethers.providers.Web3Provider(instance);
        signer = provider.getSigner();
        
        // Get user account
        const userAccount = await signer.getAddress();
        account.value = userAccount;
        
        console.log("Wallet connected successfully:", userAccount);
        
        // Login to backend and get user data
        const user = await loginAndFetchUser(userAccount);
        
        if (user) {
            isConnected.value = true;
            console.log("Backend login successful");
            return user;
        } else {
            console.log("Backend login failed, disconnecting wallet");
            await disconnectWallet();
            connectionError.value = "Backend authentication failed";
            return null;
        }

    } catch (error) {
        console.error("Connection error:", error);
        
        // Handle specific error types
        if (error.message && error.message.includes("User Rejected")) {
            connectionError.value = "Connection cancelled by user";
        } else if (error.message && error.message.includes("already pending")) {
            connectionError.value = "Connection request already pending. Please wait and try again.";
        } else {
            connectionError.value = error.message || "Connection failed";
        }
        
        // Clean up on error
        await disconnectWallet();
        return null;
    } finally {
        isConnecting = false;
    }
};

const disconnectWallet = async () => {
    console.log("Disconnecting wallet...");
    
    try {
        // Clear cached provider
        if (web3ModalInstance) {
            web3ModalInstance.clearCachedProvider();
        }
        
        // Reset all state
        provider = null;
        signer = null;
        account.value = null;
        isConnected.value = false;
        connectionError.value = null;
        isConnecting = false;
        
        // Clear the Web3Modal instance to ensure fresh state on next connect
        web3ModalInstance = null;
        
        console.log("Wallet disconnected successfully");
    } catch (error) {
        console.error("Error during disconnect:", error);
    }
};

// --- The Composable that exposes the functionality ---
export function useWeb3() {
    return {
        connectWallet,
        disconnectWallet,
        account: readonly(account),
        isConnected: readonly(isConnected),
        connectionError: readonly(connectionError),
        isConnecting: readonly(ref(isConnecting)),
    };
} 