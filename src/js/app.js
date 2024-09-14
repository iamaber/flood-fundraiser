const App = {
    web3: null,
    contract: null,
    account: null,

    init: async function() {
        try {
            // Check if MetaMask is installed
            if (typeof window.ethereum !== 'undefined') {
                // Request account access
                await window.ethereum.request({ method: 'eth_requestAccounts' });
                App.web3 = new Web3(window.ethereum);
            } else {
                throw "Please install MetaMask!";
            }

            // Load contract data
            const response = await fetch('FloodFund.json');
            const contractJson = await response.json();
            App.contract = TruffleContract(contractJson);
            App.contract.setProvider(App.web3.currentProvider);

            // Get user account
            const accounts = await App.web3.eth.getAccounts();
            App.account = accounts[0];

            // Update UI
            document.getElementById('metamask-status').textContent = `Connected with: ${App.account}`;

            // Set up event listeners
            App.bindEvents();

        } catch (error) {
            console.error("Could not connect to contract or blockchain:", error);
        }
    },

    bindEvents: function() {
        document.getElementById('registration-form').addEventListener('submit', App.registerDonor);
        document.getElementById('donation-form').addEventListener('submit', App.donate);
        document.getElementById('get-donation-info').addEventListener('click', App.getDonationInfo);
        document.getElementById('get-donor-info').addEventListener('click', App.getDonorInfo);
    },

    registerDonor: async function(event) {
        event.preventDefault();
        const name = document.getElementById('name').value;
        const mobile = document.getElementById('mobile').value;

        try {
            const instance = await App.contract.deployed();
            await instance.registerDonor(name, mobile, { from: App.account });
            alert('Registration successful!');
        } catch (error) {
            console.error("Error registering donor:", error);
            alert('Registration failed. See console for details.');
        }
    },

    donate: async function(event) {
        event.preventDefault();
        const mobile = document.getElementById('donor-mobile').value;
        const region = parseInt(document.getElementById('region').value);
        const amount = document.getElementById('amount').value;

        try {
            const instance = await App.contract.deployed();
            await instance.donate(region, mobile, { from: App.account, value: amount });
            alert('Donation successful!');
        } catch (error) {
            console.error("Error donating:", error);
            alert('Donation failed. See console for details.');
        }
    },

    getDonationInfo: async function() {
        try {
            const instance = await App.contract.deployed();
            const total = await instance.getTotalDonation();
            const sylhet = await instance.getDonationAmount(0);
            const chittagongSouth = await instance.getDonationAmount(1);
            const chittagongNorth = await instance.getDonationAmount(2);

            const info = `
                Total Donations: ${App.web3.utils.fromWei(total, 'ether')} ETH
                Sylhet: ${App.web3.utils.fromWei(sylhet, 'ether')} ETH
                Chittagong South: ${App.web3.utils.fromWei(chittagongSouth, 'ether')} ETH
                Chittagong North: ${App.web3.utils.fromWei(chittagongNorth, 'ether')} ETH
            `;
            document.getElementById('donation-info').textContent = info;
        } catch (error) {
            console.error("Error getting donation info:", error);
            alert('Failed to get donation info. See console for details.');
        }
    },

    getDonorInfo: async function() {
        const donorAddress = document.getElementById('donor-address').value;

        try {
            const instance = await App.contract.deployed();
            const [name, mobile] = await instance.getDonorInfo(donorAddress);
            document.getElementById('donor-info').textContent = `Name: ${name}, Mobile: ${mobile}`;
        } catch (error) {
            console.error("Error getting donor info:", error);
            alert('Failed to get donor info. See console for details.');
        }
    }
};

window.addEventListener('load', function() {
    App.init();
});