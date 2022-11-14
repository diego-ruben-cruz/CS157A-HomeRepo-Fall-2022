/*
 * Description: Banking System for proj01, stateless.
 * 
 * Name: Diego Cruz
 * SID: 013540384
 * 
 * Course: CS 157A
 * Section: 02
 * Homework: proj01
 * Date: 13 November 2022
 */

import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.FormattableFlags;
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = ("INSERT INTO p1.customer (name, gender, age, pin) VALUES ('%s', '%s', %s, %s);");
			// %s denotes a string concatenation which you can then combine with
			// String.format which then replaces the concatenations with your
			// desired replacements
			stmt.executeUpdate(String.format(query, name, gender, age, pin)); // jdbc statement that executes insertion
			stmt.close();
			con.close();
			System.out.println(":: CREATE NEW CUSTOMER - SUCCESS");
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "INSERT INTO p1.account (id, type, balance, status) VALUES (%s, '%s', %s, '%s')";
			stmt.executeUpdate(String.format(query, id, type, amount, "A"));
			System.out.println(":: OPEN ACCOUNT - SUCCESS");
			stmt.close();
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "UPDATE p1.account SET p1.account.status = 'I' WHERE p1.account.number = %s;";
			stmt.executeUpdate(String.format(query, accNum));
			System.out.println(":: CLOSE ACCOUNT - SUCCESS");
			stmt.close();
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "UPDATE p1.account SET balance = balance + %s WHERE number = %s;";
			stmt.executeUpdate(String.format(query, amount, accNum));
			System.out.println(":: DEPOSIT - SUCCESS");
			stmt.close();
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
			if (!BankingSystem.hasTheFunds(accNum, amount)) {
				throw new TailoredException("NOT ENOUGH FUNDS");
			}
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "UPDATE p1.account SET balance = balance - %s WHERE number = %s;";
			stmt.executeUpdate(String.format(query, amount, accNum));
			System.out.println(":: WITHDRAW - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println(":: WITHDRAW - ERROR - " + e.getMessage());
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT number, balance FROM p1.account WHERE id = %s AND status = 'A';";
			rs = stmt.executeQuery(String.format(query, cusID));
			stmt = con.createStatement();
			query = "SELECT SUM(balance) AS total FROM p1.account WHERE id = %s AND status = 'A';";
			rs = stmt.executeQuery(String.format(query, cusID));

			System.out.println(":: ACCOUNT SUMMARY - SUCCESS");
			stmt.close();
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT p1.customer.id, name, gender, age, SUM(balance) AS TOTAL " +
					"FROM p1.customer JOIN p1.account ON p1.customer.id = p1.account.id AND p1.account.status = 'A' " +
					"GROUP BY p1.customer.id, name, gender, age ORDER BY TOTAL DESC;";
			rs = stmt.executeQuery(query);
			System.out.println(":: REPORT A - SUCCESS");
			rs.close();
			stmt.close();
			con.close();
		} catch (Exception e) {
			System.out.println(":: REPORT A - FAILED");
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
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT AVG(balance) AS TOTAL FROM p1.customer JOIN p1.account " +
					"ON p1.customer.id = p1.account.id WHERE p1.customer.age >= %s AND p1.customer.age <= %s;";
			rs = stmt.executeQuery(String.format(query, min, max));
			System.out.println(":: REPORT B - SUCCESS");
			rs.close();
			stmt.close();
			con.close();
		} catch (Exception e) {
			System.out.println(":: REPORT B - FAILED");
			e.printStackTrace();
		}
	}

	/*
	 * Anything beyond this point will contain validity checks
	 * as well as in-house solutions for catching errors that might not
	 * be communicated from SQL to jdbc
	 */

	/**
	 * A custom exception handling class to outline specific
	 * condition failures.
	 * 
	 * Mainly for internal use
	 * 
	 * @param errMessage Error message string to later be printed to console
	 */
	private static class TailoredException extends Exception {
		public TailoredException(String errMessage) {
			super(errMessage);
		}
	}

	// The following will be validity checks for the p1.customer relation

	/**
	 * Checks if the customer exists using an id
	 * 
	 * @param id The customer id to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean customerExists(String id) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT id FROM p1.customer WHERE id = %s";
			rs = stmt.executeQuery(String.format(query, id));
			rs.next();
			int retrievedID = rs.getInt(1);
			rs.close();
			stmt.close();
			con.close();
			if (Integer.parseInt(id) == retrievedID) {
				return true;
			} else
				return false;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the customer id is above 0.
	 * 
	 * @param id The id to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean idIsValid(String id) {
		try {
			return Integer.parseInt(id) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the name is a valid string less than or equal to 15 chars
	 * 
	 * @param name The name to be checked.
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean nameIsValid(String name) {
		return name != null && name.length() <= 15;
	}

	/**
	 * Checks if the gender is a valid entry that is either 'M' or 'F'
	 * 
	 * @param gender The gender to be checked.
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean genderIsValid(String gender) {
		return gender.equals("M") || gender.equals("F");
	}

	/**
	 * Checks if the age is above 0.
	 * 
	 * @param age The age to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean ageIsValid(String age) {
		try {
			return Integer.parseInt(age) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the pin code is above 0.
	 * 
	 * @param pin The pin to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean pinIsValid(String pin) {
		try {
			return Integer.parseInt(pin) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	// The following will be validity checks for the p1.account relation

	/**
	 * Checks if the account exists regardless of activity
	 * 
	 * @param accNum The account number to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean accountExists(String accNum) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT number FROM p1.account WHERE number = %s";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			int number = rs.getInt(1);
			rs.close();
			stmt.close();
			con.close();
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if there are sufficient funds in a withdrawal or transfer.
	 * 
	 * @param accNum The account number used for the attempted transaction.
	 * @param amount The amount used for the attempted transaction
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean hasTheFunds(String accNum, String amount) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT balance from p1.account WHERE number = %s";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			int currentBalance = rs.getInt(1);
			rs.close();
			stmt.close();
			con.close();

			if (currentBalance >= Integer.parseInt(amount)) {
				return true;
			}

			else {
				return false;
			}
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the account type is either 'C' for Checking or 'S' for savings
	 * 
	 * @param type The type to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean typeIsValid(String type) {
		return type.equals("C") || type.equals("S");
	}

	/**
	 * Checks if an account is active
	 * 
	 * @param accNum The account number to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean accountIsActive(String accNum) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT status FROM p1.account WHERE number = %s AND status = 'A'";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			String status = rs.getString(1);
			rs.close();
			stmt.close();
			con.close();
			return status.equals("A");
		} catch (Exception e) {
			return false;
		}
	}

	// The following will be validity checks that have more to do with Java than
	// JDBC-SQL

	/**
	 * Checks if an amount is a valid integer for use in Banking System
	 * transactions.
	 * 
	 * @param amount The amount to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean amountIsValid(String amount) {
		try {
			return Integer.parseInt(amount) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the account number is a valid integer for use in Banking System
	 * 
	 * @param accNum The account number to be checked
	 * @return Boolean value for use in creating Tailored Exceptions
	 */
	public static boolean accNumIsValid(String accNum) {
		try {
			return Integer.parseInt(accNum) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

}