// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Open-Source Patent Registry
 * @dev A decentralized patent registration system for transparent patent management
 */
contract Project {
    
    struct Patent {
        uint256 patentId;
        string title;
        string description;
        address inventor;
        uint256 registrationDate;
        bool isActive;
    }
    
    // State variables
    uint256 private patentCounter;
    mapping(uint256 => Patent) public patents;
    mapping(address => uint256[]) public inventorPatents;
    
    // Events
    event PatentRegistered(
        uint256 indexed patentId,
        string title,
        address indexed inventor,
        uint256 registrationDate
    );
    
    event PatentDeactivated(
        uint256 indexed patentId,
        address indexed inventor
    );
    
    event PatentUpdated(
        uint256 indexed patentId,
        string newDescription
    );
    
    /**
     * @dev Register a new patent
     * @param _title Title of the patent
     * @param _description Detailed description of the patent
     * @return patentId The unique ID of the registered patent
     */
    function registerPatent(
        string memory _title,
        string memory _description
    ) public returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        patentCounter++;
        uint256 newPatentId = patentCounter;
        
        patents[newPatentId] = Patent({
            patentId: newPatentId,
            title: _title,
            description: _description,
            inventor: msg.sender,
            registrationDate: block.timestamp,
            isActive: true
        });
        
        inventorPatents[msg.sender].push(newPatentId);
        
        emit PatentRegistered(
            newPatentId,
            _title,
            msg.sender,
            block.timestamp
        );
        
        return newPatentId;
    }
    
    /**
     * @dev Retrieve patent details by patent ID
     * @param _patentId The unique ID of the patent
     * @return patentId The unique ID of the patent
     * @return title The title of the patent
     * @return description The description of the patent
     * @return inventor The address of the patent inventor
     * @return registrationDate The timestamp when patent was registered
     * @return isActive The status of the patent (active/inactive)
     */
    function getPatent(uint256 _patentId) public view returns (
        uint256 patentId,
        string memory title,
        string memory description,
        address inventor,
        uint256 registrationDate,
        bool isActive
    ) {
        require(_patentId > 0 && _patentId <= patentCounter, "Invalid patent ID");
        
        Patent memory patent = patents[_patentId];
        
        return (
            patent.patentId,
            patent.title,
            patent.description,
            patent.inventor,
            patent.registrationDate,
            patent.isActive
        );
    }
    
    /**
     * @dev Update patent description (only by original inventor)
     * @param _patentId The unique ID of the patent to update
     * @param _newDescription Updated description of the patent
     */
    function updatePatentDescription(
        uint256 _patentId,
        string memory _newDescription
    ) public {
        require(_patentId > 0 && _patentId <= patentCounter, "Invalid patent ID");
        require(patents[_patentId].inventor == msg.sender, "Only inventor can update");
        require(patents[_patentId].isActive, "Patent is not active");
        require(bytes(_newDescription).length > 0, "Description cannot be empty");
        
        patents[_patentId].description = _newDescription;
        
        emit PatentUpdated(_patentId, _newDescription);
    }
    
    /**
     * @dev Deactivate a patent (only by original inventor)
     * @param _patentId The unique ID of the patent to deactivate
     */
    function deactivatePatent(uint256 _patentId) public {
        require(_patentId > 0 && _patentId <= patentCounter, "Invalid patent ID");
        require(patents[_patentId].inventor == msg.sender, "Only inventor can deactivate");
        require(patents[_patentId].isActive, "Patent already deactivated");
        
        patents[_patentId].isActive = false;
        
        emit PatentDeactivated(_patentId, msg.sender);
    }
    
    /**
     * @dev Get all patent IDs registered by a specific inventor
     * @param _inventor Address of the inventor
     * @return Array of patent IDs
     */
    function getInventorPatents(address _inventor) public view returns (uint256[] memory) {
        return inventorPatents[_inventor];
    }
    
    /**
     * @dev Get total number of patents registered
     * @return Total patent count
     */
    function getTotalPatents() public view returns (uint256) {
        return patentCounter;
    }
}
