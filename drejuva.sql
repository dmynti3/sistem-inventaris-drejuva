-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 22, 2023 at 02:10 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `drejuva`
--

-- --------------------------------------------------------

--
-- Table structure for table `data_produk`
--

CREATE TABLE `data_produk` (
  `id_produk` int(11) NOT NULL,
  `kode_produk` varchar(128) NOT NULL,
  `nama_produk` varchar(128) NOT NULL,
  `stok_produk` varchar(128) NOT NULL,
  `id_jenisproduk` int(11) NOT NULL,
  `id_satuanproduk` int(11) NOT NULL,
  `id_supplier` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `data_produk`
--

INSERT INTO `data_produk` (`id_produk`, `kode_produk`, `nama_produk`, `stok_produk`, `id_jenisproduk`, `id_satuanproduk`, `id_supplier`) VALUES
(67, 'NP-002', 'paracetamol', '0', 30, 12, 10),
(69, 'NP-004', 'Serum jerawat', '10', 29, 13, 10),
(78, 'NP-006', 'Serum', '10', 29, 13, 10);

-- --------------------------------------------------------

--
-- Table structure for table `expired`
--

CREATE TABLE `expired` (
  `id_exp` int(11) NOT NULL,
  `kode_tm` varchar(128) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `tgl_exp` date NOT NULL,
  `stok` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expired`
--

INSERT INTO `expired` (`id_exp`, `kode_tm`, `id_produk`, `tgl_exp`, `stok`) VALUES
(72, 'TM-00001', 69, '2023-09-30', 10),
(73, 'TM-00002', 78, '2023-09-01', 10);

--
-- Triggers `expired`
--
DELIMITER $$
CREATE TRIGGER `deletestok` AFTER DELETE ON `expired` FOR EACH ROW BEGIN
	UPDATE data_produk
    SET stok_produk = (stok_produk - OLD.stok)
    WHERE id_produk = OLD.id_produk;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tambahstok` AFTER INSERT ON `expired` FOR EACH ROW BEGIN
	UPDATE data_produk SET stok_produk = stok_produk + NEW.stok
    WHERE id_produk = NEW.id_produk;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ubahstok` AFTER UPDATE ON `expired` FOR EACH ROW BEGIN
	UPDATE data_produk
    SET stok_produk = (stok_produk - OLD.stok) + NEW.stok
    WHERE id_produk = NEW.id_produk;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `jenis_produk`
--

CREATE TABLE `jenis_produk` (
  `id_jenisproduk` int(11) NOT NULL,
  `jenis_produk` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jenis_produk`
--

INSERT INTO `jenis_produk` (`id_jenisproduk`, `jenis_produk`) VALUES
(29, 'Skincare'),
(30, 'Obat');

-- --------------------------------------------------------

--
-- Table structure for table `laporan_keluar`
--

CREATE TABLE `laporan_keluar` (
  `id_laporankeluar` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `kode_tk` varchar(128) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah_produk` int(11) NOT NULL,
  `keterangan` text NOT NULL,
  `id_exp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `laporan_keluar`
--
DELIMITER $$
CREATE TRIGGER `hapuslp` AFTER DELETE ON `laporan_keluar` FOR EACH ROW BEGIN
	UPDATE expired
    SET stok = (stok + OLD.jumlah_produk)
    WHERE id_exp = OLD.id_exp;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `kurangiexp` AFTER INSERT ON `laporan_keluar` FOR EACH ROW BEGIN
	UPDATE expired
    SET stok = stok - NEW.jumlah_produk
    WHERE id_exp = NEW.id_exp;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ubahexpired` AFTER UPDATE ON `laporan_keluar` FOR EACH ROW BEGIN
	UPDATE expired
    SET stok = (stok + OLD.jumlah_produk) - NEW.jumlah_produk
    WHERE id_exp = OLD.id_exp;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `laporan_masuk`
--

CREATE TABLE `laporan_masuk` (
  `id_laporanmasuk` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `kode_transaksi` varchar(128) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `jumlah_produk` int(11) NOT NULL,
  `expired` date NOT NULL,
  `harga` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `laporan_masuk`
--

INSERT INTO `laporan_masuk` (`id_laporanmasuk`, `tanggal`, `kode_transaksi`, `id_produk`, `jumlah_produk`, `expired`, `harga`) VALUES
(99, '2023-09-09', 'TM-00001', 69, 10, '2023-09-30', '500000'),
(100, '2023-09-09', 'TM-00002', 78, 10, '2023-09-01', '500000');

--
-- Triggers `laporan_masuk`
--
DELIMITER $$
CREATE TRIGGER `hapusexpired` AFTER DELETE ON `laporan_masuk` FOR EACH ROW BEGIN
    DELETE FROM expired WHERE kode_tm = OLD.kode_transaksi;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateexpired` AFTER UPDATE ON `laporan_masuk` FOR EACH ROW BEGIN
	UPDATE expired
    SET stok = (stok - OLD.jumlah_produk) + NEW.jumlah_produk,
    tgl_exp = (tgl_exp - OLD.expired) + NEW.expired
    WHERE kode_tm = NEW.kode_transaksi;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengguna`
--

CREATE TABLE `pengguna` (
  `id` int(11) NOT NULL,
  `nama` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `gambar` varchar(128) NOT NULL,
  `password` varchar(256) NOT NULL,
  `role_id` int(11) NOT NULL,
  `is_active` int(11) NOT NULL,
  `date_created` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna`
--

INSERT INTO `pengguna` (`id`, `nama`, `email`, `gambar`, `password`, `role_id`, `is_active`, `date_created`) VALUES
(11, 'damay', 'damayanti1900018118@webmail.uad.ac.id', 'default.jpg', '$2y$10$lRgnNryOFE1FXOB6YNrdrerAQQ53MCsjJftMlWf/ABfez3IymxcWG', 2, 1, 1693060694),
(16, 'damayanti', 'damayantisumbawa1@gmail.com', 'foto_resmi1.jpg', 'damayanti', 1, 1, 0),
(17, 'Damayanti', 'damayantisumbawa@gmail.com', 'default.jpg', '$2y$10$fPDPuZeLVXu5jmHxk5rlvOSvZwzgQ11Vg057dGl0bxWxrVlVvLMWq', 2, 0, 1694223034),
(18, 'dilla', 'dillaadindaputri@gmail.com', 'default.jpg', '$2y$10$wTrl9K4reWj8sRIU5Md2ROEhm1LVAWWPP8iRSKzw2zAlwfF47CQKa', 2, 0, 1694223137);

-- --------------------------------------------------------

--
-- Table structure for table `pengguna_akses_menu`
--

CREATE TABLE `pengguna_akses_menu` (
  `id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `menu_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna_akses_menu`
--

INSERT INTO `pengguna_akses_menu` (`id`, `role_id`, `menu_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 2),
(4, 1, 3),
(5, 1, 4),
(6, 1, 5),
(7, 2, 4),
(8, 2, 5);

-- --------------------------------------------------------

--
-- Table structure for table `pengguna_menu`
--

CREATE TABLE `pengguna_menu` (
  `id` int(11) NOT NULL,
  `menu` varchar(128) NOT NULL,
  `icon` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna_menu`
--

INSERT INTO `pengguna_menu` (`id`, `menu`, `icon`) VALUES
(1, 'Admin', 'fa fa-fw fa-solid fa-lock'),
(2, 'User', 'fa fa-fw fa-solid fa-user'),
(3, 'Data', 'fa fa-fw fa-solid fa-database'),
(4, 'Transaksi', 'fa fa-fw fa-solid fa-handshake'),
(5, 'Laporan', 'fa fa-fw fa-solid fa-folder');

-- --------------------------------------------------------

--
-- Table structure for table `pengguna_sub_menu`
--

CREATE TABLE `pengguna_sub_menu` (
  `id` int(11) NOT NULL,
  `menu_id` int(11) NOT NULL,
  `title` varchar(128) NOT NULL,
  `url` varchar(128) NOT NULL,
  `is_active` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna_sub_menu`
--

INSERT INTO `pengguna_sub_menu` (`id`, `menu_id`, `title`, `url`, `is_active`) VALUES
(10, 1, 'Dashboard', 'Admin', 1),
(11, 1, 'Daftar Pengguna', 'User/data_pengguna', 1),
(12, 2, 'Profil', 'User', 1),
(13, 3, 'Data Produk', 'Data', 1),
(14, 3, 'Jenis Produk', 'Data/jenis_produk', 1),
(15, 3, 'Satuan Produk', 'Data/satuan_produk', 1),
(16, 3, 'Data Supplier', 'Data/data_supplier', 1),
(17, 4, 'Produk Masuk', 'Transaksi', 1),
(18, 4, 'Produk Keluar', 'Transaksi/produk_keluar', 1),
(19, 5, 'Laporan Produk Masuk', 'Laporan', 1),
(20, 5, 'Stok Gudang', 'Laporan/laporan_gudang', 1),
(21, 5, 'Laporan Produk Keluar', 'Laporan/produk_keluar', 1),
(22, 5, 'Laporan Supplier', 'Laporan/laporan_supplier', 1),
(23, 2, 'Edit Profil', 'User/edit_profil', 1),
(24, 2, 'Ubah Password', 'User/ubah_password', 1);

-- --------------------------------------------------------

--
-- Table structure for table `satuan_produk`
--

CREATE TABLE `satuan_produk` (
  `id_sp` int(11) NOT NULL,
  `satuan_produk` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `satuan_produk`
--

INSERT INTO `satuan_produk` (`id_sp`, `satuan_produk`) VALUES
(12, 'Pcs'),
(13, 'botol');

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id_supplier` int(11) NOT NULL,
  `kode_supplier` varchar(128) NOT NULL,
  `nama_supplier` varchar(128) NOT NULL,
  `alamat_supplier` varchar(128) NOT NULL,
  `no_hp_supplier` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id_supplier`, `kode_supplier`, `nama_supplier`, `alamat_supplier`, `no_hp_supplier`) VALUES
(10, 'SP-002', 'PT.Atma Jaya2', 'Surabaya2', '087654321232');

-- --------------------------------------------------------

--
-- Table structure for table `tokens`
--

CREATE TABLE `tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tokens`
--

INSERT INTO `tokens` (`id`, `user_id`, `email`, `token`, `created_at`) VALUES
(46, 16, 'damayantisumbawa@gmail.com', '439d20d86c8fd65db5061e9289a3d7ad', '2023-09-08 20:30:42'),
(47, 18, 'dillaadindaputri@gmail.com', '82a77bb6d53e098c3fa6a681d3b63ad6', '2023-09-08 20:32:29');

-- --------------------------------------------------------

--
-- Table structure for table `user_role`
--

CREATE TABLE `user_role` (
  `id` int(11) NOT NULL,
  `role` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_role`
--

INSERT INTO `user_role` (`id`, `role`) VALUES
(1, 'admin'),
(2, 'admin bawahan');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `data_produk`
--
ALTER TABLE `data_produk`
  ADD PRIMARY KEY (`id_produk`),
  ADD KEY `id_satuanproduk` (`id_satuanproduk`),
  ADD KEY `id_supplier` (`id_supplier`),
  ADD KEY `id_jenisproduk` (`id_jenisproduk`,`id_satuanproduk`,`id_supplier`) USING BTREE;

--
-- Indexes for table `expired`
--
ALTER TABLE `expired`
  ADD PRIMARY KEY (`id_exp`);

--
-- Indexes for table `jenis_produk`
--
ALTER TABLE `jenis_produk`
  ADD PRIMARY KEY (`id_jenisproduk`);

--
-- Indexes for table `laporan_keluar`
--
ALTER TABLE `laporan_keluar`
  ADD PRIMARY KEY (`id_laporankeluar`);

--
-- Indexes for table `laporan_masuk`
--
ALTER TABLE `laporan_masuk`
  ADD PRIMARY KEY (`id_laporanmasuk`);

--
-- Indexes for table `pengguna`
--
ALTER TABLE `pengguna`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengguna_akses_menu`
--
ALTER TABLE `pengguna_akses_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengguna_menu`
--
ALTER TABLE `pengguna_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengguna_sub_menu`
--
ALTER TABLE `pengguna_sub_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `satuan_produk`
--
ALTER TABLE `satuan_produk`
  ADD PRIMARY KEY (`id_sp`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id_supplier`);

--
-- Indexes for table `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_role`
--
ALTER TABLE `user_role`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `data_produk`
--
ALTER TABLE `data_produk`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT for table `expired`
--
ALTER TABLE `expired`
  MODIFY `id_exp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT for table `jenis_produk`
--
ALTER TABLE `jenis_produk`
  MODIFY `id_jenisproduk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `laporan_keluar`
--
ALTER TABLE `laporan_keluar`
  MODIFY `id_laporankeluar` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `laporan_masuk`
--
ALTER TABLE `laporan_masuk`
  MODIFY `id_laporanmasuk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `pengguna`
--
ALTER TABLE `pengguna`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `pengguna_akses_menu`
--
ALTER TABLE `pengguna_akses_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `pengguna_menu`
--
ALTER TABLE `pengguna_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pengguna_sub_menu`
--
ALTER TABLE `pengguna_sub_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `satuan_produk`
--
ALTER TABLE `satuan_produk`
  MODIFY `id_sp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `id_supplier` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tokens`
--
ALTER TABLE `tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `user_role`
--
ALTER TABLE `user_role`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `data_produk`
--
ALTER TABLE `data_produk`
  ADD CONSTRAINT `data_produk_ibfk_1` FOREIGN KEY (`id_satuanproduk`) REFERENCES `satuan_produk` (`id_sp`) ON UPDATE CASCADE,
  ADD CONSTRAINT `data_produk_ibfk_2` FOREIGN KEY (`id_supplier`) REFERENCES `supplier` (`id_supplier`) ON UPDATE CASCADE,
  ADD CONSTRAINT `data_produk_ibfk_3` FOREIGN KEY (`id_jenisproduk`) REFERENCES `jenis_produk` (`id_jenisproduk`) ON UPDATE CASCADE;

--
-- Constraints for table `tokens`
--
ALTER TABLE `tokens`
  ADD CONSTRAINT `tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `pengguna` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
