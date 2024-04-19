//
//  MovieDetailViewController.swift
//  MovieHub
//
//  Created by Duy Nguyễn on 18/04/2024.
//

import UIKit
import Reusable

final class MovieDetailViewController: UIViewController, NibReusable {

    @IBOutlet private weak var tableView: UITableView!
    var movie: Movie? {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    var movieRepository: MovieRepositoryType = MovieRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(cellType: MovieDetailInfoCell.self)
        tableView.register(cellType: CastTableViewCell.self)
        tableView.register(cellType: SimilarTableViewCell.self)
    }
    
    func loadData(movie: Movie) {
        guard let id = movie.id else { return }
         getMovieDetail(id: id)
    }
    
    private func getMovieDetail(id: Int) {
        loading(true)
        movieRepository.getMovieDetail(id: id) { [weak self] result in
            guard let self else { return }
            self.loading(false)
            switch result {
            case .success(let movieDetail):
                self.movie = movieDetail
            case .failure(let error):
                switch error {
                case let AppError.normalError(message):
                    self.showError(message: message)
                default:
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MovieSectionType.total.rawValue
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = MovieSectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        switch section {
        case .info:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MovieDetailInfoCell.self)
            guard let movieDetail = movie else { return UITableViewCell() }
            cell.configCell(movie: movieDetail)
            cell.selectionStyle = .none
            return cell
            
        case .cast:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CastTableViewCell.self)
            guard let movieDetail = movie else { return UITableViewCell() }
            cell.prepareDatasource(data: movieDetail.credits?.cast ?? [])
            cell.tappedCast = { [weak self] cast in
                guard let self else { return }
                self.toActorDetailScreen(cast: cast)
            }
            cell.selectionStyle = .none
            return cell
            
        case .similar:
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SimilarTableViewCell.self)
            guard let movieDetail = movie else { return UITableViewCell() }
            cell.configCell(data: movieDetail.similar?.results ?? [])
            cell.tappedSimilar = { [weak self] movie in
                guard let self else { return }
                self.toMovieDetailScreen(movie: movie)
            }
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension MovieDetailViewController {
    func toMovieDetailScreen(movie: Movie) {
        let vc = MovieDetailViewController()
        vc.loadData(movie: movie)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toActorDetailScreen(cast: Cast) {

    }
}