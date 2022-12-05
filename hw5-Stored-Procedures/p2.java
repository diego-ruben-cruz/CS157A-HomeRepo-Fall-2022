import java.util.Scanner;

/*
 * Description: Banking System CLI for proj01, active.
 * 
 * Name: Diego Cruz
 * SID: 013540384
 * 
 * Course: CS 157A
 * Section: 02
 * Homework: proj01
 * Date: 13 November 2022
 * 
 * To run:
 * 
 * Run directory cmd: javac *.java
 * 
 * Run container command: db2 -tvf p1_create.sql
 * 
 * Run directory cmd: java -cp ";./db2jcc4.jar" p1 ./db.properties
 */
public class p2 {
    private static Scanner inputScanner;
    private static String idNum;
    private static String accNum;

    public static void main(String[] args) {
        System.out.println(":: PROGRAM START");
        if (args.length < 1) {
            System.out.println("It needs database properties file name");
        } else {
            BankingSystem.init(args[0]);
            BankingSystem.testConnection();
            inputScanner = new Scanner(System.in);
            mainMenu();
        }
    }

    /**
     * Main menu for CLI interface, offers different options for prospective user.
     */
    private static void mainMenu() {
        System.out.println("---------------------------------------------------");
        System.out.println("Welcome to IBM myBank - CLI Banking Interface");
        System.out.println("---------------------------------------------------");
        while (true) {
            System.out.println("\nMain Menu:");
            System.out.println("  1 => New Customer - Sign Up");
            System.out.println("  2 => Ret Customer - Log In");
            System.out.println("  3 => Exit Program");
            System.out.print("Enter a number to choose from the above menu: ");
            String ch = inputScanner.next();
            if (ch.equals("1"))
                createNewCustomer();
            else if (ch.equals("2"))
                login();
            else if (ch.equals("3"))
                break;
            else
                System.out.println("Invalid input, Try Again.");
        }
        System.out.println("Done");
    }

    private static void createNewCustomer() {
        System.out.println("\nCreate a customer profile");
        System.out.print("Enter your name (up to 15 chars): ");
        String name = inputScanner.next();
        System.out.print("Enter your gender (M/F): ");
        String gender = inputScanner.next();
        System.out.print("Enter your age: ");
        String age = inputScanner.next();
        System.out.print("Enter your desired PIN code: ");
        String pin = inputScanner.next();
        BankingSystem.newCustomer(name, gender, age, pin);
    }

    /**
     * Login modal, verifies that the user is in the system before proceeding.
     */
    private static void login() {
        System.out.print("\nPlease enter your Customer ID: ");
        String id = inputScanner.next();
        System.out.print("Enter your PIN code: ");
        String PIN = inputScanner.next();
        if (id.equals("0") && PIN.equals("0")) {
            System.out.println("Admin Panel Activated");
            adminSession();
        } else if (BankingSystem.login(id, PIN)) {
            idNum = id;
            customerSession();
        }
    }

    /**
     * Menu Screen modal for authenticated customers.
     */
    private static void customerSession() {
        while (true) {
            System.out.println("\nCustomer Menu:");
            System.out.println("  1 => Open Account");
            System.out.println("  2 => Close Account");
            System.out.println("  3 => Deposit");
            System.out.println("  4 => Withdraw");
            System.out.println("  5 => Transfer");
            System.out.println("  6 => Account Summary");
            System.out.println("  7 => Exit");
            System.out.print("Enter a number to choose from the above menu: ");
            String choice = inputScanner.next();
            if (choice.equals("1"))
                openAccount();
            else if (choice.equals("2"))
                closeAccount();
            else if (choice.equals("3"))
                deposit();
            else if (choice.equals("4"))
                withdraw();
            else if (choice.equals("5"))
                transfer();
            else if (choice.equals("6"))
                BankingSystem.accountSummary(idNum);
            else if (choice.equals("7")) {
                System.out.println("Logged out");
                break;
            } else
                System.out.println("Invalid input, try again.");
        }
    }

    /**
     * Menu Screen modal for authenticated Admins.
     */
    private static void adminSession() {
        while (true) {
            System.out.println("\nAdmin Menu:");
            System.out.println("  1 => Account Summary for a Customer");
            System.out.println("  2 => Report A");
            System.out.println("  3 => Report B");
            System.out.println("  4 => Exit");
            System.out.print("Enter a number to choose from above menu: ");
            String choice = inputScanner.next();
            if (choice.equals("1"))
                adminAccountSummary();
            else if (choice.equals("2"))
                BankingSystem.reportA();
            else if (choice.equals("3"))
                reportB();
            else if (choice.equals("4")) {
                System.out.println("Admin Panel Deactivated");
                break;
            } else
                System.out.println("Invalid input, try again.");
        }
    }

    /**
     * Open Account modal for authenticated customers.
     */
    private static void openAccount() {
        System.out.print("\nEnter the type of account you want to open (C/S): ");
        String type = inputScanner.next();
        System.out.print("Enter the initial amount in your account: ");
        String amount = inputScanner.next();
        BankingSystem.openAccount(idNum, type, amount);
    }

    /**
     * Close Account modal for authenticated customers.
     */
    private static void closeAccount() {
        System.out.print("\nEnter the account number you want to close: ");
        String accNum = inputScanner.next();
        BankingSystem.closeAccount(accNum);

    }

    /**
     * Deposit into Account modal for authenticated customers.
     */
    private static void deposit() {
        System.out.print("\nEnter the account number you want to deposit to: ");
        String accNum = inputScanner.next();
        System.out.print("Enter the amount you want to deposit: ");
        String amount = inputScanner.next();
        BankingSystem.deposit(accNum, amount);

    }

    /**
     * Withdraw from Account modal for authenticated customers.
     */
    private static void withdraw() {
        System.out.print("\nEnter the account number you want to withdraw from: ");
        accNum = inputScanner.next();
        System.out.print("Enter the amount you want to withdraw: ");
        String amount = inputScanner.next();
        BankingSystem.withdraw(accNum, amount);
    }

    /**
     * Transfer Amount modal for authenticated customers.
     */
    private static void transfer() {
        System.out.print("\nEnter the account number you want to transfer from: ");
        String srcAccNum = inputScanner.next();
        System.out.print("Enter the account number you want to transfer to: ");
        String destAccNum = inputScanner.next();
        System.out.print("enter the amount you want to transfer: ");
        String amount = inputScanner.next();
        BankingSystem.transfer(srcAccNum, destAccNum, amount);
    }

    /**
     * Account Summary modal for authenticated Admins.
     * Allows Admin to view account summary of any customer in the database.
     */
    private static void adminAccountSummary() {
        System.out.print("Enter the customer id for the summary: ");
        String ID = inputScanner.next();
        BankingSystem.accountSummary(ID);
    }

    /**
     * Report B modal for authenticated Admins.
     * Refer to reportB method in BankingSystem documentation
     */
    private static void reportB() {
        System.out.print("\nEnter min age bound: ");
        String min = inputScanner.next();
        System.out.print("Enter max age bound: ");
        String max = inputScanner.next();
        BankingSystem.reportB(min, max);
    }
}
