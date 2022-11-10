// package src;

import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

/**
 * Manage connection to database and perform SQL statements.
 */
public class BankingSystem {
	// Connection properties
	private static String driver;
	private static String url;
	private static String username;
	private static String password;

	// JDBC Objects
	private static Connection con;
	private static Statement stmt;
	private static ResultSet rs;

	/**
	 * Initialize database connection given properties file.
	 * 
	 * @param filename name of properties file
	 */
	public static void init(String filename) {
		try {
			Properties props = new Properties(); // Create a new Properties object
			FileInputStream input = new FileInputStream(filename); // Create a new FileInputStream object using our
																	// filename parameter
			props.load(input); // Load the file contents into the Properties object
			driver = props.getProperty("jdbc.driver"); // Load the driver
			url = props.getProperty("jdbc.url"); // Load the url
			username = props.getProperty("jdbc.username"); // Load the username
			password = props.getProperty("jdbc.password"); // Load the password
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Test database connection.
	 */
	public static void testConnection() {
		System.out.println(":: TEST - CONNECTING TO DATABASE");
		try {
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			con.close();
			System.out.println(":: TEST - SUCCESSFULLY CONNECTED TO DATABASE");
		} catch (Exception e) {
			System.out.println(":: TEST - FAILED CONNECTED TO DATABASE");
			e.printStackTrace();
		}
	}

	/**
	 * Create a new customer.
	 * 
	 * @param name   customer name
	 * @param gender customer gender
	 * @param age    customer age
	 * @param pin    customer pin
	 */
	public static void newCustomer(String name, String gender, String age, String pin) {
		System.out.println(":: CREATE NEW CUSTOMER - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			stmt.executeQuery("INSERT INTO p1.customer(name, gender, age, pin) VALUES (" + name + ", " + gender
					+ ", " + age + ", " + pin + ");");
			System.out.println(":: CREATE NEW CUSTOMER - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: CREATE NEW CUSTOMER - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Open a new account.
	 * 
	 * @param id     customer id
	 * @param type   type of account
	 * @param amount initial deposit amount
	 */
	public static void openAccount(String id, String type, String amount) {
		System.out.println(":: OPEN ACCOUNT - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			stmt.executeQuery("INSERT INTO p1.account(id, type, balance) VALUES (" + id + ", " + type
					+ ", " + amount + ");");
			System.out.println(":: OPEN ACCOUNT - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: OPEN ACCOUNT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Close an account.
	 * 
	 * @param accNum account number
	 */
	public static void closeAccount(String accNum) {
		System.out.println(":: CLOSE ACCOUNT - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			stmt.executeQuery("DELETE FROM p1.account WHERE p1.account.number = " + accNum + ";");
			System.out.println(":: CLOSE ACCOUNT - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: CLOSE ACCOUNT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Deposit into an account.
	 * 
	 * @param accNum account number
	 * @param amount deposit amount
	 */
	public static void deposit(String accNum, String amount) {
		System.out.println(":: DEPOSIT - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			stmt.executeQuery(
					"UPDATE p1.account SET balance = balance + " + amount + " WHERE number = " + accNum + ";");
			System.out.println(":: DEPOSIT - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: DEPOSIT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Withdraw from an account.
	 * 
	 * @param accNum account number
	 * @param amount withdraw amount
	 */
	public static void withdraw(String accNum, String amount) {
		System.out.println(":: WITHDRAW - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			stmt.executeQuery(
					"UPDATE p1.account SET balance = balance - " + amount + " WHERE number = " + accNum + ";");
			System.out.println(":: WITHDRAW - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: WITHDRAW - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Transfer amount from source account to destination account.
	 * 
	 * @param srcAccNum  source account number
	 * @param destAccNum destination account number
	 * @param amount     transfer amount
	 */
	public static void transfer(String srcAccNum, String destAccNum, String amount) {
		System.out.println(":: TRANSFER - RUNNING");
		try {
			BankingSystem.withdraw(srcAccNum, amount);
			BankingSystem.deposit(destAccNum, amount);
			System.out.println(":: TRANSFER - SUCCESS");
		} catch (Exception e) {
			System.out.println(":: TRANSFER - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display account summary.
	 * 
	 * @param cusID customer ID
	 */
	public static void accountSummary(String cusID) {
		System.out.println(":: ACCOUNT SUMMARY - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			rs = stmt.executeQuery("SELECT number, balance FROM p1.account WHERE id = " + cusID + ";");
			stmt = con.createStatement();
			rs = stmt.executeQuery("SELECT SUM(balance) AS total FROM p1.account WHERE id = " + cusID + ";");
			System.out.println(":: ACCOUNT SUMMARY - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: ACCOUNT SUMMARY - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display Report A - Customer Information with Total Balance in Decreasing
	 * Order.
	 */
	public static void reportA() {
		System.out.println(":: DISPLAY REPORT A - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			rs = stmt.executeQuery(
					"SELECT id, name, gender, age, SUM(balance) AS TOTAL FROM p1.customer JOIN p1.account ON p1.customer.id = p1.account.id GROUP BY id ORDER BY TOTAL DESC;");
			System.out.println(":: ACCOUNT SUMMARY - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: ACCOUNT SUMMARY - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display Report B - Average Total Balance within an age range
	 * 
	 * @param min minimum age
	 * @param max maximum age
	 */
	public static void reportB(String min, String max) {
		System.out.println(":: REPORT B - RUNNING");
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			rs = stmt.executeQuery(
					"SELECT AVG(balance) AS TOTAL FROM p1.customer JOIN p1.account ON p1.customer.id = p1.account.id WHERE p2.customer.age >= "
							+ min + " AND p1.customer.age <= " + max + ";");
			System.out.println(":: REPORT B - SUCCESS");
			con.close();
		} catch (Exception e) {
			System.out.println(":: REPORT B - FAILED");
			e.printStackTrace();
		}
	}
}
