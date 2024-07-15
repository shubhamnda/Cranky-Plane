//
//  PaymentManager.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 04/07/24.
//

import StoreKit

class PaymentManager:NSObject ,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    


    
 
    private var purchaseCompletion: ((Bool) -> Void)?

    
    enum Product: String, CaseIterable {
        case   nonAdsPremium = "co.shubhamnanda.premium"
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let oProduct = response.products.first {
            print("available")
            self.purchase(product: oProduct)
        }
        else {
            print("error not available")
            purchaseCompletion?(false)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState{
            case .purchasing :
                print("purchasing")
            case .purchased :
                SKPaymentQueue.default().finishTransaction(transaction)
                print("purchased")
                
                UserDefaults.standard.set(true, forKey: "isPremiumUser")
                NotificationCenter.default.post(name: NSNotification.Name("PremiumPurchased"), object: nil)
                purchaseCompletion?(true)
               purchaseCompletion = nil
               
               
                      
               
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("failed")
                UserDefaults.standard.set(false, forKey: "isPremiumUser")
                purchaseCompletion?(false)
               purchaseCompletion = nil
               
            default : break
            }
        }
    }
    
    func buyPremium(completion: @escaping (Bool) -> Void){
      
        if SKPaymentQueue.canMakePayments(){
            let set: Set<String> = [Product.nonAdsPremium.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
            completion(true)
        }
    
    }
    func purchase(product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
   
    
}

