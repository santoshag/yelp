import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterViewControllerDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var switchStates: [Int:Bool]!
    var searchTerm: String!
    var categories: [[String:String]]!
    var searchCategories: [String]!
    var searchDeals: Bool!
    var sortMode: YelpSortMode!
    var distanceAuto: Bool!
    var distancePoint3: Bool!
    var distance1Mile: Bool!
    var distance3Mile: Bool!
    var distance5Mile: Bool!
    var distance20Mile: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //FilterViewControllerDelegate
        
        switchStates = [Int:Bool]()
        searchTerm = "" // Tim said to use a blank search term
        categories = yelpCategories()
        searchCategories = [""]
        searchDeals = false
        sortMode = YelpSortMode.bestMatched
        distanceAuto = true
        distancePoint3 = false
        distance1Mile = false
        distance3Mile = false
        distance5Mile = false
        distance20Mile = false

        // disable automatically added insets
        self.automaticallyAdjustsScrollViewInsets = false

        // put search bar in nav bar
        navigationItem.titleView = searchBar
        
        callAPI()
        
    } // viewDidLoad

    func callAPI(){
        
        var distance: Int?
        let m2mm = 1609.34 // miles to meter multiplier
        
        if(distance20Mile == true){
            distance = Int(20.0 * m2mm)
        }else if (distance5Mile == true){
            distance = Int(5.0 * m2mm)
        }else if (distance3Mile == true){
            distance = Int(3.0 * m2mm)
        }else if (distance1Mile == true){
            distance = Int(1.0 * m2mm)
        }else if (distancePoint3 == true){
            distance = Int(0.3 * m2mm)
        }else if (distanceAuto == true){
            distance = nil
        }else{
            distance = nil
        }

        Business.searchWithTerm(
            term: searchTerm,
            sort: sortMode,
            categories: searchCategories,
            deals: searchDeals,
            distance: distance,
            completion: { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                if let businesses = businesses {
                    for business in businesses {
                        print(business.name!)
                        print(business.address!)
                    }
                }
                self.filteredBusinesses = businesses
                self.tableView.reloadData()
            }
        )

/*
        Business.searchWithTerm(
            term: searchTerm,
            completion: { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                if let businesses = businesses {
                    for business in businesses {
                        print(business.name!)
                        print(business.address!)
                    }
                }
                self.filteredBusinesses = businesses
                self.tableView.reloadData()
            }
        )
*/
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    } // callAPI()
    
    // MARK: FilterViewController Delegate
    
    func filterViewController(
        filterViewController: FilterViewController,
        didSwitchStates switchStates: [Int:Bool],
        deals: Bool,
        sortMode: YelpSortMode,
        distanceAuto: Bool,
        distancePoint3: Bool,
        distance1Mile: Bool,
        distance3Mile: Bool,
        distance5Mile: Bool,
        distance20Mile: Bool
        ){

        self.switchStates = switchStates
        searchCategories = [String]()
        searchDeals = deals
        self.sortMode = sortMode
        self.distanceAuto = distanceAuto
        self.distancePoint3 = distancePoint3
        self.distance1Mile = distance1Mile
        self.distance3Mile = distance3Mile
        self.distance5Mile = distance5Mile
        self.distance20Mile = distance20Mile

        for (k,v) in switchStates{
            if(v == true){
                searchCategories.append(categories[k]["code"]!)
            }
        }
        callAPI()
    }
    
    // MARK: UISearchBar Delegates
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.filteredBusinesses = self.businesses
        }else{
            self.filteredBusinesses = []
            for business in businesses{
                if let name = business.name{
                    if(name.range(of: searchText, options: .caseInsensitive) != nil){
                        self.filteredBusinesses.append(business)
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        self.filteredBusinesses = self.businesses
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // MARK: UITableView Delegates
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = filteredBusinesses[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses == nil {
            return 0
        }else{
            return filteredBusinesses.count
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "FiltersSegue"){
            let nav = segue.destination as! UINavigationController
            let fvc = nav.topViewController as! FilterViewController

            fvc.delegate = self
            fvc.switchStates = switchStates
            fvc.searchDeals = searchDeals
            fvc.sortMode = sortMode
            fvc.distanceAuto = distanceAuto
            fvc.distancePoint3 = distancePoint3
            fvc.distance1Mile = distance1Mile
            fvc.distance3Mile = distance3Mile
            fvc.distance5Mile = distance5Mile
            fvc.distance20Mile = distance20Mile
        }
    }
    
    private func yelpCategories() -> [[String:String]]{
        
        let categories = [["name" : "Afghan", "code": "afghani"],
                          ["name" : "African", "code": "african"],
                          ["name" : "American, New", "code": "newamerican"],
                          ["name" : "American, Traditional", "code": "tradamerican"],
                          ["name" : "Arabian", "code": "arabian"],
                          ["name" : "Argentine", "code": "argentine"],
                          ["name" : "Armenian", "code": "armenian"],
                          ["name" : "Asian Fusion", "code": "asianfusion"],
                          ["name" : "Asturian", "code": "asturian"],
                          ["name" : "Australian", "code": "australian"],
                          ["name" : "Austrian", "code": "austrian"],
                          ["name" : "Baguettes", "code": "baguettes"],
                          ["name" : "Bangladeshi", "code": "bangladeshi"],
                          ["name" : "Barbeque", "code": "bbq"],
                          ["name" : "Basque", "code": "basque"],
                          ["name" : "Bavarian", "code": "bavarian"],
                          ["name" : "Beer Garden", "code": "beergarden"],
                          ["name" : "Beer Hall", "code": "beerhall"],
                          ["name" : "Beisl", "code": "beisl"],
                          ["name" : "Belgian", "code": "belgian"],
                          ["name" : "Bistros", "code": "bistros"],
                          ["name" : "Black Sea", "code": "blacksea"],
                          ["name" : "Brasseries", "code": "brasseries"],
                          ["name" : "Brazilian", "code": "brazilian"],
                          ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                          ["name" : "British", "code": "british"],
                          ["name" : "Buffets", "code": "buffets"],
                          ["name" : "Bulgarian", "code": "bulgarian"],
                          ["name" : "Burgers", "code": "burgers"],
                          ["name" : "Burmese", "code": "burmese"],
                          ["name" : "Cafes", "code": "cafes"],
                          ["name" : "Cafeteria", "code": "cafeteria"],
                          ["name" : "Cajun/Creole", "code": "cajun"],
                          ["name" : "Cambodian", "code": "cambodian"],
                          ["name" : "Canadian", "code": "New)"],
                          ["name" : "Canteen", "code": "canteen"],
                          ["name" : "Caribbean", "code": "caribbean"],
                          ["name" : "Catalan", "code": "catalan"],
                          ["name" : "Chech", "code": "chech"],
                          ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                          ["name" : "Chicken Shop", "code": "chickenshop"],
                          ["name" : "Chicken Wings", "code": "chicken_wings"],
                          ["name" : "Chilean", "code": "chilean"],
                          ["name" : "Chinese", "code": "chinese"],
                          ["name" : "Comfort Food", "code": "comfortfood"],
                          ["name" : "Corsican", "code": "corsican"],
                          ["name" : "Creperies", "code": "creperies"],
                          ["name" : "Cuban", "code": "cuban"],
                          ["name" : "Curry Sausage", "code": "currysausage"],
                          ["name" : "Cypriot", "code": "cypriot"],
                          ["name" : "Czech", "code": "czech"],
                          ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                          ["name" : "Danish", "code": "danish"],
                          ["name" : "Delis", "code": "delis"],
                          ["name" : "Diners", "code": "diners"],
                          ["name" : "Dumplings", "code": "dumplings"],
                          ["name" : "Eastern European", "code": "eastern_european"],
                          ["name" : "Ethiopian", "code": "ethiopian"],
                          ["name" : "Fast Food", "code": "hotdogs"],
                          ["name" : "Filipino", "code": "filipino"],
                          ["name" : "Fish & Chips", "code": "fishnchips"],
                          ["name" : "Fondue", "code": "fondue"],
                          ["name" : "Food Court", "code": "food_court"],
                          ["name" : "Food Stands", "code": "foodstands"],
                          ["name" : "French", "code": "french"],
                          ["name" : "French Southwest", "code": "sud_ouest"],
                          ["name" : "Galician", "code": "galician"],
                          ["name" : "Gastropubs", "code": "gastropubs"],
                          ["name" : "Georgian", "code": "georgian"],
                          ["name" : "German", "code": "german"],
                          ["name" : "Giblets", "code": "giblets"],
                          ["name" : "Gluten-Free", "code": "gluten_free"],
                          ["name" : "Greek", "code": "greek"],
                          ["name" : "Halal", "code": "halal"],
                          ["name" : "Hawaiian", "code": "hawaiian"],
                          ["name" : "Heuriger", "code": "heuriger"],
                          ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                          ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                          ["name" : "Hot Dogs", "code": "hotdog"],
                          ["name" : "Hot Pot", "code": "hotpot"],
                          ["name" : "Hungarian", "code": "hungarian"],
                          ["name" : "Iberian", "code": "iberian"],
                          ["name" : "Indian", "code": "indpak"],
                          ["name" : "Indonesian", "code": "indonesian"],
                          ["name" : "International", "code": "international"],
                          ["name" : "Irish", "code": "irish"],
                          ["name" : "Island Pub", "code": "island_pub"],
                          ["name" : "Israeli", "code": "israeli"],
                          ["name" : "Italian", "code": "italian"],
                          ["name" : "Japanese", "code": "japanese"],
                          ["name" : "Jewish", "code": "jewish"],
                          ["name" : "Kebab", "code": "kebab"],
                          ["name" : "Korean", "code": "korean"],
                          ["name" : "Kosher", "code": "kosher"],
                          ["name" : "Kurdish", "code": "kurdish"],
                          ["name" : "Laos", "code": "laos"],
                          ["name" : "Laotian", "code": "laotian"],
                          ["name" : "Latin American", "code": "latin"],
                          ["name" : "Live/Raw Food", "code": "raw_food"],
                          ["name" : "Lyonnais", "code": "lyonnais"],
                          ["name" : "Malaysian", "code": "malaysian"],
                          ["name" : "Meatballs", "code": "meatballs"],
                          ["name" : "Mediterranean", "code": "mediterranean"],
                          ["name" : "Mexican", "code": "mexican"],
                          ["name" : "Middle Eastern", "code": "mideastern"],
                          ["name" : "Milk Bars", "code": "milkbars"],
                          ["name" : "Modern Australian", "code": "modern_australian"],
                          ["name" : "Modern European", "code": "modern_european"],
                          ["name" : "Mongolian", "code": "mongolian"],
                          ["name" : "Moroccan", "code": "moroccan"],
                          ["name" : "New Zealand", "code": "newzealand"],
                          ["name" : "Night Food", "code": "nightfood"],
                          ["name" : "Norcinerie", "code": "norcinerie"],
                          ["name" : "Open Sandwiches", "code": "opensandwiches"],
                          ["name" : "Oriental", "code": "oriental"],
                          ["name" : "Pakistani", "code": "pakistani"],
                          ["name" : "Parent Cafes", "code": "eltern_cafes"],
                          ["name" : "Parma", "code": "parma"],
                          ["name" : "Persian/Iranian", "code": "persian"],
                          ["name" : "Peruvian", "code": "peruvian"],
                          ["name" : "Pita", "code": "pita"],
                          ["name" : "Pizza", "code": "pizza"],
                          ["name" : "Polish", "code": "polish"],
                          ["name" : "Portuguese", "code": "portuguese"],
                          ["name" : "Potatoes", "code": "potatoes"],
                          ["name" : "Poutineries", "code": "poutineries"],
                          ["name" : "Pub Food", "code": "pubfood"],
                          ["name" : "Rice", "code": "riceshop"],
                          ["name" : "Romanian", "code": "romanian"],
                          ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                          ["name" : "Rumanian", "code": "rumanian"],
                          ["name" : "Russian", "code": "russian"],
                          ["name" : "Salad", "code": "salad"],
                          ["name" : "Sandwiches", "code": "sandwiches"],
                          ["name" : "Scandinavian", "code": "scandinavian"],
                          ["name" : "Scottish", "code": "scottish"],
                          ["name" : "Seafood", "code": "seafood"],
                          ["name" : "Serbo Croatian", "code": "serbocroatian"],
                          ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                          ["name" : "Singaporean", "code": "singaporean"],
                          ["name" : "Slovakian", "code": "slovakian"],
                          ["name" : "Soul Food", "code": "soulfood"],
                          ["name" : "Soup", "code": "soup"],
                          ["name" : "Southern", "code": "southern"],
                          ["name" : "Spanish", "code": "spanish"],
                          ["name" : "Steakhouses", "code": "steak"],
                          ["name" : "Sushi Bars", "code": "sushi"],
                          ["name" : "Swabian", "code": "swabian"],
                          ["name" : "Swedish", "code": "swedish"],
                          ["name" : "Swiss Food", "code": "swissfood"],
                          ["name" : "Tabernas", "code": "tabernas"],
                          ["name" : "Taiwanese", "code": "taiwanese"],
                          ["name" : "Tapas Bars", "code": "tapas"],
                          ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                          ["name" : "Tex-Mex", "code": "tex-mex"],
                          ["name" : "Thai", "code": "thai"],
                          ["name" : "Traditional Norwegian", "code": "norwegian"],
                          ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                          ["name" : "Trattorie", "code": "trattorie"],
                          ["name" : "Turkish", "code": "turkish"],
                          ["name" : "Ukrainian", "code": "ukrainian"],
                          ["name" : "Uzbek", "code": "uzbek"],
                          ["name" : "Vegan", "code": "vegan"],
                          ["name" : "Vegetarian", "code": "vegetarian"],
                          ["name" : "Venison", "code": "venison"],
                          ["name" : "Vietnamese", "code": "vietnamese"],
                          ["name" : "Wok", "code": "wok"],
                          ["name" : "Wraps", "code": "wraps"],
                          ["name" : "Yugoslav", "code": "yugoslav"]]
        
        return(categories)
    }

    
}
