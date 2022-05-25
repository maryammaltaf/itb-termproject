pragma solidity >=0.8.4;

contract Auction {
	address public owner;
	uint public startTime;
	uint public endTime;
	uint public minPrice = 0.001 ether;
	address private highestBidder;
	address private secondHighestBidder;
	mapping(address => uint) private bids;

    enum AucStatus { Complete, Active, InActive, Cancelled }
	    AucStatus public auctionStatus;

	constructor() {
		owner = msg.sender;
		auctionStatus = AucStatus.InActive;
	}

	modifier onlyOwner {
		require(owner == msg.sender, "sender is not owner");
        _;
	}

	function auctionWinner() external view returns (address) {
		require(auctionStatus == AucStatus.Complete, "auction not completed");
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
		if (auctionStatus == AucStatus.Complete && msg.sender == highestBidder) {
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
		auctionStatus = AucStatus.Active;
		startTime = block.timestamp;
		endTime = endTime_;
	}

    function endAuction() external onlyOwner {
        //highest binding bid goes to the owner
		uint highestBindingBid = bids[secondHighestBidder] + 1;
        payable(msg.sender).transfer(highestBindingBid);
		auctionStatus = AucStatus.Complete;
	}

	function cancelAuction() external onlyOwner {
        require(auctionStatus == AucStatus.Active, "auction not active");
        //auction is cancelled
		auctionStatus = AucStatus.Cancelled;
	}
}
