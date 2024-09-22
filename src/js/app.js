App = {
    web3Provider: null,
    contracts: {},

    init: async function() {
        return App.initWeb3();
    },

    initWeb3: async function() {

        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {

                await window.ethereum.request({ method: "eth_requestAccounts" });
            } catch (error) {
                console.error("User denied account access...");
            }
        }

        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }

        else {
            App.web3Provider = new Web3.providers.HttpProvider("http://localhost:8545");
        }

        window.web3 = new Web3(App.web3Provider);

        return App.initContract();
    },

    initContract: function() {

        $.getJSON('FloodFund.json', function(data) {
            App.contracts.FloodFund = TruffleContract(data);
            App.contracts.FloodFund.setProvider(App.web3Provider);

            return App.render();
        });
    },

    render: function() {
        var metamaskStatus = $('#metamask-status');
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }

            if (accounts.length === 0) {
                metamaskStatus.text('Please connect to Metamask');
            } else {
                metamaskStatus.text('Connected: ' + accounts[0]);
            }
        });
    },

    registerDonor: function(event) {
        event.preventDefault();

        const donorName = $('#name').val();
        const donorMobile = $('#mobile').val();

        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }

            const account = accounts[0];

            App.contracts.FloodFund.deployed().then(function(instance) {
                return instance.registerDonor(donorName, donorMobile, { from: account });
            }).then(function(result) {
                console.log("Donor registered", result);
            }).catch(function(err) {
                console.error(err);
            });
        });
    },

    donate: async function(event) {
        event.preventDefault();
        const contractInstance = await App.contracts.FloodFund.deployed()
        const donorMobile = $('#donor-mobile').val();
        const region = $('#region').val();
        const amount = $('#amount').val();
        

        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            
            const weiAmount = web3.toWei(amount, 'ether');
            const account = accounts[0];
            const result = contractInstance.donate( region, donorMobile, { from: account, value: weiAmount } )

        });

        

    },

    getDonationInfo: function() {
        App.contracts.FloodFund.deployed().then(function(instance) {
            return instance.getBalance();
        }).then(function(result) {
            const sylhet = result[0];
            const ctgNorth = result[1];
            const ctgSouth = result[2];
            const total = result[3];
    
            $('#donation-info').text(`Sylhet: ${sylhet}, Chittagong North: ${ctgNorth}, Chittagong South: ${ctgSouth}, Total donations: ${total}`);
        }).catch(function(err) {
            console.error(err);
        });
    },

    getDonorInfo: function() {
        const donorAddress = $('#donor-address').val();

        App.contracts.FloodFund.deployed().then(function(instance) {
            return instance.getDonorInfoByAddress(donorAddress);
        }).then(function(result) {
            $('#donor-info').text(`Name: ${result[0]}, Mobile: ${result[1]}`);
        }).catch(function(err) {
            console.error(err);
        });
    }
};

$(function() {
    $(window).on('load', function() {
        App.init();

        $('#registration-form').submit(App.registerDonor);
        $('#donation-form').submit(App.donate);
        $('#get-donation-info').click(App.getDonationInfo);
        $('#get-donor-info').click(App.getDonorInfo);
    });
});
