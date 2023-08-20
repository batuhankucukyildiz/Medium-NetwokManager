import Foundation

struct User : Decodable {
    var userId : Int
    var id : Int
    var title : String
    var completed : Bool
}

protocol EndpointProtocol{
    var baseUrl: String {get}
    var path : String {get}
    var method : HttpMethod {get}
    var header : [String : String]? {get}
    func request () -> URLRequest
}

enum HttpMethod : String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum EndPoint{
    case getUser
}


extension EndPoint : EndpointProtocol{

    
    var baseUrl: String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .getUser : return "/todos/1"
        }
    }
    
    var method: HttpMethod {
        switch self{
        case .getUser : return .get
        }
    }
    
    var header: [String : String]? {
        return nil
    }
    
    func request() -> URLRequest {
        guard var component = URLComponents(string: baseUrl) else{
            fatalError("Invalid Error")
        }
        component.path = path
        var request = URLRequest(url: component.url!)
        request.httpMethod =  method.rawValue
        return request
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init(){}
    
    func request <T:Decodable> (_ endpoint : EndPoint , completion : @escaping (Result<T , Error>) ->Void) ->Void {
       
        let urlSessionTask = URLSession.shared.dataTask(with: endpoint.request()) {(data ,response , error) in
            if let error = error {
                print(error)
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    // Successful request status
                    print("Request successful: \(response.statusCode)")
                } else {
                    // Unsuccessful request status
                    print("Request failed: \(response.statusCode)")
                }
            }
            
            if let data = data {
                do {
                    let jsonData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(jsonData))
                    
                }catch let error {
                    completion(.failure(error))
                }
            }
            
        }
        urlSessionTask.resume()
    }
    
    
    func getUser(completion: @escaping (Result<User , Error>) ->Void) -> Void {
        let endpoint = EndPoint.getUser
        request(endpoint, completion: completion)
    }
}


NetworkManager.shared.getUser { responseData in
    print(responseData)
}
