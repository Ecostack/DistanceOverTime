//
//  DistanceOverTimeApp.swift
//  DistanceOverTime
//
//  Created by Sebastian Scheibe on 21/03/2024.
//

import SwiftUI

import HealthKit


import Foundation
import HealthKit

class HealthDataViewModel: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var steps: Double = 0
    @Published var stepsLastHour: Double = 0
    @Published var stepsLast30Minutes: Double = 0
        @Published var stepsLast10Minutes: Double = 0
        @Published var stepsLastMinute: Double = 0
    
    private var timer: Timer?
    
    init() {
        requestAuthorization()
    }
    
    func fetchIntervalData(for minutes: Int, updating keyPath: WritableKeyPath<HealthDataViewModel, Double>) {
           let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
           let now = Date()
           let startDate = Calendar.current.date(byAdding: .minute, value: minutes, to: now)
           
           let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
           
           let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
               DispatchQueue.main.async {
                   self?[keyPath: keyPath] = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
               }
           }
           
           healthStore.execute(query)
       }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
         let readTypes = Set([stepType])
        
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { [weak self] success, error in
            if success {
                // Start fetching steps regularly after authorization
                self?.fetchStepsData()
                self?.fetchIntervalData(for: -60, updating: \.stepsLastHour)
                            self?.fetchIntervalData(for: -30, updating: \.stepsLast30Minutes)
                            self?.fetchIntervalData(for: -10, updating: \.stepsLast10Minutes)
                            self?.fetchIntervalData(for: -1, updating: \.stepsLastMinute)
            } else {
                // Handle errors or denied permissions
                print("Authorization denied or error: \(String(describing: error))")
            }
        }
    }

    
    func startFetchingStepsEveryFiveSeconds() {
            // Invalidate the old timer if it exists
            timer?.invalidate()
            
            // Set up a new timer to fetch steps every 5 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.fetchStepsData()
                self?.fetchIntervalData(for: -60, updating: \.stepsLastHour)
                            self?.fetchIntervalData(for: -30, updating: \.stepsLast30Minutes)
                            self?.fetchIntervalData(for: -10, updating: \.stepsLast10Minutes)
                            self?.fetchIntervalData(for: -1, updating: \.stepsLastMinute)
                
            }
            
            // This line is important to make sure the timer works when the user interacts with the UI
            RunLoop.current.add(timer!, forMode: .common)
        }
        
    
    // Call this method to stop the timer when you no longer need to fetch steps
       func stopFetchingSteps() {
           timer?.invalidate()
           timer = nil
       }
       
       deinit {
           // Invalidate the timer when the view model is deinitialized
           timer?.invalidate()
       }
    

    
//    func fetchLastHourData() {
//        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//        let now = Date()
//        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -1, to: now)
//        
//        let predicate = HKQuery.predicateForSamples(withStart: modifiedDate, end: now, options: .strictStartDate)
//        
//        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
//            DispatchQueue.main.async {
//                self?.stepsLastHour = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
//            }
//        }
//        
//        healthStore.execute(query)
//    }
//    
    func fetchStepsData() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            DispatchQueue.main.async {
                self?.steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            }
        }
        
        healthStore.execute(query)
    }
}



@main
struct DistanceOverTimeApp: App {
    


    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
