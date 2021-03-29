//
//  ViewController.swift
//  Debug-Labyrinth
//
//  Created by Borchert, Otto on 3/26/21.
//  Copyright © 2021 Missouri Southern State University - CIS 395. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /* Change this constant to contain your name.
         *
         * WARNING: Once you've set set this constant and started exploring your maze,
         * do NOT edit the value of yourName. Changing yourName will change which
         * maze you get back, which might invalidate all your hard work!
         */
        let yourName = "TODO: Replace this string with your name.";

        /* Change these constants to contain the paths out of your mazes. */
        let pathOutOfMaze = "TODO: Replace this string with your path out of the normal maze.";
        let pathOutOfTwistyMaze = "TODO: Replace this string with your path out of the twisty maze.";

        let startLocation = MazeUtilities.mazeFor(yourName);
            
            /* Set a breakpoint here to explore your maze! */
            
        if MazeUtilities.isPathToFreedom(startLocation, pathOutOfMaze) {
          print("Congratulations! You've found a way out of your labyrinth.");
        } else {
          print("Sorry, but you're still stuck in your labyrinth.");
        }
            
            
        let twistyStartLocation = MazeUtilities.twistyMazeFor(yourName);
            
        /* Set a breakpoint here to explore your twisty maze! */
            
        if (MazeUtilities.isPathToFreedom(twistyStartLocation, pathOutOfTwistyMaze)) {
           print("Congratulations! You've found a way out of your twisty labyrinth.");
        } else {
           print("Sorry, but you're still stuck in your twisty labyrinth.");
        }
      

    }


}

