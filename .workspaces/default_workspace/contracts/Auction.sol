pragma solidity >=0.8.4;

contract Auction {
	address public owner;
	uint public startTime;
	uint public endTime;
	uint public minPrice = 0.001 ether;
	address private highestBidder;
	address private secondHighestBidder;
	mapping(address => uint) private bids;

    enum AuctionStatus { InActive, Active, Cancelled, Complete }
	    AuctionStatus public auctionStatus;

	constructor() {
		owner = msg.sender;
		auctionStatus = AuctionStatus.InActive;
	}

	modifier onlyOwner {
		require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
	}

	function auctionWinner() external view returns (address) {
		require(auctionStatus == AuctionStatus.Complete, "Auction is not complete");
		return highestBidder;
	}

    function placeBid() external payable {
        //update bids array with msg sender against their value
    	bids[msg.sender] = msg.value;

        //if its the sender assign him highestBidder and secondHighestBidder 
		if (highestBidder == address(0)) {
			highestBidder = msg.sender;
			secondHighestBidder = msg.sender;
		}
        //compare the value with highestBidder if its greater update the highestBidder and secndHighestBidder accordingly 
        else if (msg.value > bids[highestBidder]) {
			secondHighestBidder = highestBidder;
			highestBidder = msg.sender;
		}
        //compare the value with secondHighestBidder if its greater update the secndHighestBidder accordingly
        else if (msg.value > bids[secondHighestBidder]) {
			secondHighestBidder = msg.sender;
		}
	}

    function withdrawBid() external {
        //check the highestBidder and calculate highestBindingBid that is 1eth more than the secondHigherBidder
		if (auctionStatus == AuctionStatus.Complete && msg.sender == highestBidder) {
			uint highestBindingBid = bids[secondHighestBidder] + 1;
			uint refundedAmount = bids[msg.sender] - highestBindingBid;
            //transfer the remaining amount back to the highest bidder 
			payable(msg.sender).transfer(refundedAmount);
		} else {
            //transfer the amount back to all other bidders 
			payable(msg.sender).transfer(bids[msg.sender]);
		}
	}

    function startAuction(uint endTime_) external onlyOwner {
        //owner starts the auction
		auctionStatus = AuctionStatus.Active;
		startTime = block.timestamp;
		endTime = endTime_;
	}

    function endAuction() external onlyOwner {
        //highest binding bid goes to the owner
		uint highestBindingBid = bids[secondHighestBidder] + 1;
        payable(msg.sender).transfer(highestBindingBid);
		auctionStatus = AuctionStatus.Complete;
	}

	function cancelAuction() external onlyOwner {
        require(auctionStatus == AuctionStatus.Active, "Auction is not active");
        //auction is cancelled
		auctionStatus = AuctionStatus.Cancelled;
	}
}
